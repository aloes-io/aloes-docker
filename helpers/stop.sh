#!/bin/bash

stop_services() {
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
  fi
  if [ -z "$1" ]; then
    echo "Environment name is required to stop services"
    exit 1
  fi

  local compose_file="$(pwd)/docker-compose.yml"
  # if [ "$1" == "production" ]; then
    # compose_file="$(pwd)/docker-compose-prod.yml"
  # fi

  echo "Stop $compose_file containers"
  docker-compose --compatibility -f ${compose_file} down
}

stop () {
  if [ -z "$1" ]; then
    echo "Environment name is required to stop containers"
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
  stop_services $ENV &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Stopped services with status $? in $elapsedseconds s"

}
