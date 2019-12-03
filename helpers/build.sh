#!/bin/bash

build_proxy () {
  if ! [ -x "$(command -v docker)" ]; then
    echo 'Error: docker is not installed.' >&2
    exit 1
  fi
  if [ -z "$1" ]; then
    echo "Environment name is required to build proxy"
    exit 1
  fi

  local env_file
  if [ -z "$2" ]; then
    env_file="$(pwd)/.env"
  else 
    env_file=$2
  fi

  local tcp_server_port=$(read_var LB_TCP_SERVER_PORT $env_file)
  local http_server_port=$(read_var LB_HTTP_SERVER_PORT $env_file)
  local timer_server_port=$(read_var TIMER_SERVER_PORT $env_file)
  local proxy_server_host=$(read_var PROXY_SERVER_HOST $env_file)
  local proxy_http_server_port=$(read_var PROXY_HTTP_SERVER_PORT $env_file)
  local proxy_https_server_port=$(read_var PROXY_HTTPS_SERVER_PORT $env_file)
  local proxy_mqtt_broker_port=$(read_var PROXY_MQTT_BROKER_PORT $env_file)
  local proxy_mqtts_broker_port=$(read_var PROXY_MQTTS_BROKER_PORT $env_file)
  local build_context="$(pwd)/config/nginx"
  local dockerfile="$build_context/gw-dockerfile"
  local nginx_template=./aloes-gw.template

  local ssl_ready="$3"
  # if [ "$ssl_ready" == "1" ]; then
  if [ "$1" == "production" ]; then
    nginx_template=./aloes-gw-production.template
  fi

  echo "Building proxy : $proxy_server_host $1 
  proxy HTTP port : $proxy_http_server_port 
  proxy HTTPS port : $proxy_https_server_port 
  proxy MQTT port : $proxy_mqtt_broker_port 
  proxy MQTTS port : $proxy_mqtts_broker_port 
  Binding Timer load balancer : $timer_server_port 
  Binding TCP load balancer : $tcp_server_port 
  Binding HTTP load balancer : $http_server_port " 

  if [ "$1" == "production" ]; then
    docker build --no-cache -t aloes-gw-prod -f $dockerfile $build_context --build-arg http_server_port=$http_server_port \
      --build-arg tcp_server_port=$tcp_server_port --build-arg proxy_server_host=$proxy_server_host --build-arg proxy_http_server_port=$proxy_http_server_port \
      --build-arg proxy_mqtt_broker_port=$proxy_mqtt_broker_port --build-arg proxy_https_server_port=$proxy_https_server_port \
      --build-arg proxy_mqtts_broker_port=$proxy_mqtts_broker_port --build-arg nginx_template=$nginx_template
  else
    docker build --no-cache -t aloes-gw -f $dockerfile $build_context --build-arg http_server_port=$http_server_port \
      --build-arg tcp_server_port=$tcp_server_port --build-arg timer_server_port=$timer_server_port --build-arg proxy_server_host=$proxy_server_host \
      --build-arg proxy_http_server_port=$proxy_http_server_port --build-arg proxy_mqtt_broker_port=$proxy_mqtt_broker_port \
      --build-arg nginx_template=$nginx_template
  fi
}

build_services() {
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
  fi
  if [ -z "$1" ]; then
    echo "Environment name is required to build services"
    exit 1
  fi

  local ENV=$1
  local compose_file="$(pwd)/docker-compose.yml"
  # if [ "$ENV" == "production" ]; then
  #   compose_file="$(pwd)/docker-compose.prod.yml"
  # fi
  local env_file
  if [ -z "$2" ]; then
    env_file="$(pwd)/.env"
  else 
    env_file=$2
  fi
  
  export REDIS_PASS=$(read_var REDIS_PASS $env_file)
  export REDIS_PORT=$(read_var REDIS_PORT $env_file)
  envsubst '$${REDIS_PASS},$${REDIS_PORT}' < "$(pwd)/config/redis/redis.template" > "$(pwd)/config/redis/redis.conf" 

  echo "Building $compose_file containers"
  docker-compose --compatibility -f $compose_file build
}

build () {
  if [ -z "$1" ]; then
    echo "Environment name is required to build containers"
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
    build_proxy $ENV $config
  else
    SECONDS=0
    local a=$SECONDS
    build_proxy $ENV $config &
    local process_id=$!
    wait $process_id
    local elapsedseconds=$(( SECONDS - a ))
    echo "Build proxy done with status $? in $elapsedseconds s"

    a=$SECONDS
    build_services $ENV &
    process_id=$!
    wait $process_id
    elapsedseconds=$(( SECONDS - a ))
    echo "Build services done with status $? in $elapsedseconds s"
  fi


}
