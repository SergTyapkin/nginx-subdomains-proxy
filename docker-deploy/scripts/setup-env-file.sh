cp --no-clobber ./docker-deploy/.env.example ./docker-deploy/.env
echo ""
echo "Edit .env file."
echo "Write right DOMAIN_URL without https:// and url paths!"
echo "Write right PROXY_[***] variables for each services"
echo "Be careful that your subdomains docker-containers must uses external networks with names specified in PROXY_<*>_NETWORK_NAME"
echo "[press Enter...]"
read ENTER
nano ./docker-deploy/.env
