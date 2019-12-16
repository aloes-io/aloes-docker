#!/bin/bash

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

  a=$SECONDS
  delete_services $ENV &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Deleted services with status $? in $elapsedseconds s"
}