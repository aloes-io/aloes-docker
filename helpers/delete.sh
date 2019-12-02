#!/bin/bash

delete_certbot() {
  docker stop certbot
  docker container rm certbot
}

delete_proxy() {
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

  echo "Delete proxy " 

  if [ "$1" == "production" ]; then
    # docker run --rm -itd --name aloes-gw-prod -v "$(pwd)"/config/certbot/www:/var/www/certbot -v "$(pwd)"/config/certbot/conf:/etc/letsencrypt --net="host" aloes-gw-prod
      docker stop aloes-gw-prod
      docker container rm aloes-gw-prod
    else
      docker stop aloes-gw
      docker container rm aloes-gw
  fi
}

delete_services() {
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

  echo "Delete $compose_file containers"
  # delete containers, volumes, networks
  # docker-compose --compatibility -f ${compose_file} 
}


delete () {
  if [ -z "$1" ]; then
    echo "Environment name is required to stop containers"
    exit 1
  fi
  
  local ENV=$1
  local config="$(pwd)/.env"
  if [ ! -f "$config" ]; then
    echo "No environment file found, start by creating one"
    exit 1
  fi

  local SECONDS=0
  local a=$SECONDS
  delete_proxy $ENV $config &
  local process_id=$!
  wait $process_id
  local elapsedseconds=$(( SECONDS - a ))
  echo "Deleted proxy with status $? in $elapsedseconds s"

  if [ "$ENV" == "production" ]; then
    a=$SECONDS
    delete_certbot $ENV &
    process_id=$!
    wait $process_id
    elapsedseconds=$(( SECONDS - a ))
    echo "Deleted certbot with status $? in $elapsedseconds s"
  fi
  
  a=$SECONDS
  delete_services $ENV &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Started services with status $? in $elapsedseconds s"
}