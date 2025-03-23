cd docker-deploy || exit
docker compose down
docker compose up -d nginx-certbot
STR="docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d ${DOMAIN_URL}"
for proxy_num in $(seq 1 "$(. "docker-deploy/.env"; eval "echo \${PROXY_SERVICES_COUNT}" | tr -dc [0-9])"); do
  STR="${STR} -d $(. "docker-deploy/.env"; eval "echo \${PROXY_${proxy_num}_SUBDOMAIN}" | tr -dc [a-zA-Z0-9\_\.\-]).${DOMAIN_URL}"
done
eval "${STR}"
sudo chmod ugo+rwx -R ./certbot/
