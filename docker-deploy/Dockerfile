ARG DEBIAN_RELEASE
ARG NGINX_RELEASE
FROM debian:${DEBIAN_RELEASE:-12-slim} as build
ARG DEBIAN_FRONTEND=noninteractive
USER root

# copy project to workdir
COPY .. /home/nginx-proxy
WORKDIR /home/nginx-proxy

# install envsubst
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    gettext-base

#install nginx modules
#RUN apt-get update -y && apt-get install  --no-install-recommends -y \
#    nginx-plus-module-brotli

ARG DOMAIN_URL
ARG PROXY_SERVICES_COUNT
RUN export DOLLAR="$" && \
    mkdir ./docker-deploy/nginx/locations/_http-not-substituted && \
    mkdir ./docker-deploy/nginx/locations/_https-not-substituted && \
    for proxy_num in $(seq 1 ${PROXY_SERVICES_COUNT}); do \
      export PROXY_NUMBER=${proxy_num} && \
      eval "export PROXY_${proxy_num}_SUBDOMAIN=$(. "docker-deploy/.env"; eval "echo \${PROXY_${proxy_num}_SUBDOMAIN}" | tr -dc [a-zA-Z0-9\_\-\.])" && \
      eval "export PROXY_${proxy_num}_TARGET_HTTP_PORT=$(. "docker-deploy/.env"; eval "echo \${PROXY_${proxy_num}_TARGET_HTTP_PORT}" | tr -dc [0-9])" && \
      eval "export PROXY_${proxy_num}_TARGET_HTTPS_PORT=$(. "docker-deploy/.env"; eval "echo \${PROXY_${proxy_num}_TARGET_HTTPS_PORT}" | tr -dc [0-9])" && \
      # Copy nginx proxy files into _[***]_not_substituted folder \
      cp ./docker-deploy/nginx/proxy_http.template.conf ./docker-deploy/nginx/locations/_http-not-substituted/proxy_${proxy_num}_http.conf  && \
      cp ./docker-deploy/nginx/proxy_https.template.conf ./docker-deploy/nginx/locations/_https-not-substituted/proxy_${proxy_num}_https.conf  && \
      # Envsubst the .conf files into http or https folder \
      envsubst < ./docker-deploy/nginx/locations/_http-not-substituted/proxy_${proxy_num}_http.conf > ./docker-deploy/nginx/locations/http/proxy_${proxy_num}_http.conf && \
      envsubst < ./docker-deploy/nginx/locations/_https-not-substituted/proxy_${proxy_num}_https.conf > ./docker-deploy/nginx/locations/https/proxy_${proxy_num}_https.conf; \
    done && \
    \
    # substitute env variables into nginx.conf and http + https folders \
    export DOMAIN_URL=${DOMAIN_URL} && \
    envsubst < ./docker-deploy/nginx/nginx.conf > ./docker-deploy/nginx/_nginx-substituted.conf && \
    cd /home/nginx-proxy/docker-deploy/nginx/locations/http && \
    mkdir ../_http-substituted && \
    for file in *; do envsubst < $file > ../_http-substituted/$file; done && \
    cd /home/nginx-proxy/docker-deploy/nginx/locations/https && \
    mkdir ../_https-substituted && \
    for file in *; do envsubst < $file > ../_https-substituted/$file; done


FROM nginx:${NGINX_RELEASE:-1.27-alpine-slim}

# copy substituted files into nginx folder
COPY --from=build /home/nginx-proxy/docker-deploy/nginx/_nginx-substituted.conf /etc/nginx/nginx.conf
COPY --from=build /home/nginx-proxy/docker-deploy/nginx/locations/_http-substituted /etc/nginx/include_locations/http
COPY --from=build /home/nginx-proxy/docker-deploy/nginx/locations/_https-substituted /etc/nginx/include_locations/https
