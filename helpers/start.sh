#!/bin/bash

start_certbot() {
  # local entrypoint="exit TERM; while :; do certbot renew; sleep 12h & wait ${!}; done;"
  docker run -dit --restart always --name certbot -v "$(pwd)"/config/certbot/www:/var/www/certbot --entrypoint "trap" \
    -v "$(pwd)"/config/certbot/conf:/etc/letsencrypt certbot/certbot exit TERM; while :; do certbot renew; sleep 12h & wait ${!}; done;
}

start_proxy() {
  if [ -z "$1" ]; then
    echo "Environment variable name is required to start the proxy"
    exit 1
  fi

  local env_file
  if [ -z "$2" ]; then
    env_file="$(pwd)/.env"
  else 
    env_file=$2
  fi

  local TCP_SERVER_PORT=$(read_var LB_TCP_SERVER_PORT $env_file)
  local HTTP_SERVER_PORT=$(read_var LB_HTTP_SERVER_PORT $env_file)
  local TIMER_SERVER_PORT=$(read_var TIMER_SERVER_PORT $env_file)
  local PROXY_SERVER_HOST=$(read_var PROXY_SERVER_HOST $env_file)
  local PROXY_HTTP_SERVER_PORT=$(read_var PROXY_HTTP_SERVER_PORT $env_file)
  local PROXY_HTTPS_SERVER_PORT=$(read_var PROXY_HTTPS_SERVER_PORT $env_file)
  local PROXY_MQTT_BROKER_PORT=$(read_var PROXY_MQTT_BROKER_PORT $env_file)
  local PROXY_MQTTS_BROKER_PORT=$(read_var PROXY_MQTTS_BROKER_PORT $env_file)
  local NGINX_TEMPLATE=./aloes-gw.template
  
  local ssl_ready="$3"
  if [ "$ssl_ready" == "1" ]; then
    NGINX_TEMPLATE=./aloes-gw-production.template
  fi

  echo "Start proxy : $PROXY_SERVER_HOST $1 
  proxy HTTP port : $PROXY_HTTP_SERVER_PORT 
  proxy MQTT port : $PROXY_MQTT_BROKER_PORT 
  Binding Timer load balancer : $TIMER_SERVER_PORT 
  Binding TCP load balancer : $TCP_SERVER_PORT 
  Binding HTTP load balancer : $HTTP_SERVER_PORT 
  Work directory : $(pwd)" 


  if [ "$1" == "production" ]; then
    # start_certbot
    docker run -dit --restart always --name aloes-gw-prod -v "$(pwd)"/config/certbot/www:/var/www/certbot -v "$(pwd)"/config/certbot/conf:/etc/letsencrypt \
      -e "PROXY_SERVER_HOST=$PROXY_SERVER_HOST" -e "HTTP_SERVER_PORT=$HTTP_SERVER_PORT" -e "TCP_SERVER_PORT=$TCP_SERVER_PORT" -e "TIMER_SERVER_PORT=$TIMER_SERVER_PORT" \
      -e "PROXY_HTTP_SERVER_PORT=$PROXY_HTTP_SERVER_PORT" -e "PROXY_MQTT_BROKER_PORT=$PROXY_MQTT_BROKER_PORT" -e "PROXY_HTTPS_SERVER_PORT=$PROXY_HTTPS_SERVER_PORT" \
      -e "PROXY_MQTTS_BROKER_PORT=$PROXY_MQTTS_BROKER_PORT" -e "NGINX_TEMPLATE=$NGINX_TEMPLATE" --net="host" aloes-gw-prod
  else
    docker run -dit --restart unless-stopped --name aloes-gw -v "$(pwd)"/config/certbot/www:/var/www/certbot -e "PROXY_SERVER_HOST=$PROXY_SERVER_HOST" \
      -e "HTTP_SERVER_PORT=$HTTP_SERVER_PORT" -e "TCP_SERVER_PORT=$TCP_SERVER_PORT" -e "TIMER_SERVER_PORT=$TIMER_SERVER_PORT" \
      -e "PROXY_HTTP_SERVER_PORT=$PROXY_HTTP_SERVER_PORT" -e "PROXY_MQTT_BROKER_PORT=$PROXY_MQTT_BROKER_PORT" -e "NGINX_TEMPLATE=$NGINX_TEMPLATE" \
      --net="host" aloes-gw
  fi
}

start_services() {
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
  fi
  if [ -z "$1" ]; then
    echo "Environment name is required to start services"
    exit 1
  fi

  local ENV=$1
  local SERVICE=''
  if [ ! -z "$2" ]; then
    SERVICE="$2"
  fi

  local compose_file="$(pwd)/docker-compose.yml"
  # if [ "$ENV" == "production" ]; then
  #   compose_file="$(pwd)/docker-compose.prod.yml"
  # fi

  export REDIS_PASS=$(read_var REDIS_PASS $env_file)
  export REDIS_PORT=$(read_var REDIS_PORT $env_file)
  envsubst '$${REDIS_PASS},$${REDIS_PORT}' < "$(pwd)/config/redis/redis.template" > "$(pwd)/config/redis/redis.conf" 
  
  echo "Start $compose_file containers"
  docker-compose --compatibility -f ${compose_file} up -d 
  # docker-compose --compatibility -f ${compose_file} up -d ${SERVICE}
}


start () {
  if [ -z "$1" ]; then
    echo "Environment name is required to start containers"
    exit 1
  fi

  local ENV=$1
  local SERVICE=$2
  local config="$(pwd)/.env"
  if [ ! -f "$config" ]; then
    echo "No environment file found, start by creating one"
    exit 1
  fi

  if [ "$SERVICE" == "proxy" ]; then
    start_proxy $ENV $config
  else
    # local SECONDS=0
    local a=$SECONDS
    start_proxy $ENV $config &
    local process_id=$!
    wait $process_id
    local elapsedseconds=$(( SECONDS - a ))
    echo "Started proxy with status $? in $elapsedseconds s"

    if [ "$ENV" == "production" ]; then
      a=$SECONDS
      start_certbot $ENV &
      process_id=$!
      wait $process_id
      elapsedseconds=$(( SECONDS - a ))
      echo "Started certbot with status $? in $elapsedseconds s"
    fi
    
    a=$SECONDS
    start_services $ENV &
    process_id=$!
    wait $process_id
    elapsedseconds=$(( SECONDS - a ))
    echo "Started services with status $? in $elapsedseconds s"
  fi
}