#!/bin/bash

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
  unset REDIS_PASS
  unset REDIS_PORT

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

  a=$SECONDS
  start_services $ENV &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Started services with status $? in $elapsedseconds s"
}