cat ./docker-deploy/docker-compose.template.yaml > ./docker-deploy/docker-compose.yaml
final_networks_string="networks:
  default:
"
proxy_services_count=$(. "docker-deploy/.env"; echo "$PROXY_SERVICES_COUNT" | tr -dc [0-9])
for proxy_num in $(seq 1 $proxy_services_count); do
  # Add "networks" to docker-compose.yaml
  proxy_network_var_name="PROXY_${proxy_num}_NETWORK_NAME"
  proxy_network_name=$(. "docker-deploy/.env"; eval "echo \${${proxy_network_var_name}} | tr -dc [a-zA-Z\-\_\.]" )
  echo "      - ${proxy_network_name}" >> ./docker-deploy/docker-compose.yaml;
  final_networks_string="${final_networks_string}  ${proxy_network_name}:
"
done
echo "${final_networks_string}" >> ./docker-deploy/docker-compose.yaml
