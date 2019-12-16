  #!/bin/bash

init_ssl () {
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
  fi

  if [ -z "$1" ]; then
    echo "Domain name is required"
    exit 1
  fi

  # domains=(example.org www.example.org)
  local domains=("$1")
  local rsa_key_size=4096
  local email="$2" # Adding a valid address is strongly recommended

  # staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits
  local staging
  if [ -z "$3" ]; then
    staging=1
  elif [ "$3" == "production" ]; then
    staging=0
  else
    staging=1
  fi

  local data_path
  if [ -z "$4" ]; then
    data_path="$(pwd)/config/certbot"
  else 
    data_path=$4
  fi
  
  echo "### Certbot conf : $data_path $email"

  if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
    echo "### Downloading recommended TLS parameters ..."
    mkdir -p "$data_path/conf"
    local nginx_ssl_conf_link=https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
    
    local res=$(curl -I -s -L $nginx_ssl_conf_link | grep "HTTP/1.1")
    if [[ "$res" != *"200"* ]]; then
      echo "$res"
      echo "Fix nginx_ssl_conf_link before trying again"
    else
      curl -s $nginx_ssl_conf_link > "$data_path/conf/options-ssl-nginx.conf"
    fi

    local ssl_dhparams_link=https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem
    res=$(curl -I -s -L $ssl_dhparams_link | grep "HTTP/1.1")
    if [[ "$res" != *"200"* ]]; then
      echo "$res"
      echo "Fix ssl_dhparams_link before trying again"
    else
      curl -s $ssl_dhparams_link > "$data_path/conf/ssl-dhparams.pem"
    fi
    echo
  fi

  echo "### Creating dummy certificate for $domains ..."
  local path="/etc/letsencrypt/live/$domains"
  mkdir -p "$data_path/conf/live/$domains"

  docker-compose -f docker-compose.yml run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:1024 -days 1\
      -keyout '$path/privkey.pem' \
      -out '$path/fullchain.pem' \
      -subj '/CN=localhost'" certbot

  sleep 1
  echo

  echo "### Starting nginx ..."
  export PROXY_CONFIG_TEMPLATE=aloes-lb-certonly.template
  docker-compose -f docker-compose.yml up --force-recreate --no-deps -d aloes-lb-1 
  # export PROXY_CONFIG_TEMPLATE=aloes-lb.template
  # docker-compose -f docker-compose.yml up --force-recreate -d aloes-lb-1 
  sleep 3
  echo

  echo "### Deleting dummy certificate for $domains ..."
  docker-compose -f docker-compose.yml run --rm --entrypoint "\
    rm -Rf /etc/letsencrypt/live/$domains && \
    rm -Rf /etc/letsencrypt/archive/$domains && \
    rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
  sleep 1
  echo

  echo "### Requesting Let's Encrypt certificate for $domains ..."
  #Join $domains to -d args
  domain_args=""
  for domain in "${domains[@]}"; do
    domain_args="$domain_args -d $domain"
  done

  # Select appropriate email arg
  case "$email" in
    "") email_arg="--register-unsafely-without-email" ;;
    *) email_arg="--email $email" ;;
  esac

  # Enable staging mode if needed
  if [ $staging != "0" ]; then staging_arg="--staging"; fi

  docker-compose -f docker-compose.yml run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
      $staging_arg \
      $email_arg \
      $domain_args \
      --rsa-key-size $rsa_key_size \
      --agree-tos \
      --force-renewal" certbot
  sleep 1
  echo

  echo "### Reloading nginx ..."
  docker-compose -f docker-compose.yml exec aloes-lb-1 nginx -s reload
}