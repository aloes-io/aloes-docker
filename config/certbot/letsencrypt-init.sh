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
  else 
    staging=$3
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
    else
      curl -s $nginx_ssl_conf_link > "$data_path/conf/options-ssl-nginx.conf"
    fi

    local ssl_dhparams_link=https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem
    res=$(curl -I -s -L $ssl_dhparams_link | grep "HTTP/1.1")
    if [[ "$res" != *"200"* ]]; then
      echo "$res"
    else
      curl -s $ssl_dhparams_link > "$data_path/conf/ssl-dhparams.pem"
    fi
    echo
  fi

  echo "### Creating dummy certificate for $domains ..."
  local path="/etc/letsencrypt/live/$domains"
  mkdir -p "$data_path/conf/live/$domains"
  
  # docker stop certbot
  # docker container rm certbot

  # --mount "type=bind,src=$data_path/conf,dst=/etc/letsencrypt"
  docker run -i --name certbot-cert -v "$data_path/conf:/etc/letsencrypt" \
    --entrypoint "/usr/bin/openssl" certbot/certbot req -x509 -nodes -newkey rsa:1024 -days 1\
      -keyout "$path/privkey.pem"\
      -out "$path/fullchain.pem"\
      -subj /CN=localhost

  docker wait certbot-cert
  docker stop certbot-cert
  docker container rm certbot-cert
  # local res=$(docker wait certbot)
  # if [[ "$res" != "0" ]]; then
  #   echo "Docker error code : $res"
  #   exit 1
  # fi
  sleep 1
  echo

  echo "### Starting nginx ..."
  docker run -d --name aloes-gw-cert -v "$data_path/www:/var/www/certbot" --net="host" aloes-gw
  sleep 3
  echo

  echo "### Deleting dummy certificate for $domains ..."
  docker run -i --name certbot-cert -v "$data_path/conf:/etc/letsencrypt" \
    --entrypoint "rm" certbot/certbot -Rf "/etc/letsencrypt/live/$domains" && \
      rm -Rf "/etc/letsencrypt/archive/$domains" && rm -Rf "/etc/letsencrypt/renewal/$domains.conf"
  docker wait certbot-cert
  docker stop certbot-cert
  docker container rm certbot-cert
  sleep 1
  # rm -Rf "$data_path/conf/live/$domains" && rm -Rf "$data_path/conf/archive/$domains" \
  #   && rm -Rf "$data_path/conf/renewal/$domains.conf"
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

  docker run -i --name certbot-cert -v "$data_path/www:/var/www/certbot" -v "$data_path/conf:/etc/letsencrypt" \
    --entrypoint "certbot" certbot/certbot certonly --non-interactive --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos --force-renewal
  
  docker stop certbot-cert
  docker container rm certbot-cert
  sleep 1
  echo

  # echo "### Reloading nginx ..."
  # docker exec -d aloes-gw-cert nginx -s reload

  echo "### Stopping nginx ..."
  docker stop aloes-gw-cert
  docker container rm aloes-gw-cert
}