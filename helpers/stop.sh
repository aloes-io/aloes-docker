#!/bin/bash

stop_certbot() {
  docker stop certbot
  docker container rm certbot
}

stop_proxy() {
  if [ -z "$1" ]; then
    echo "Environment name is required to stop proxy"
    exit 1
  fi

  echo "Stopping aloes-proxy $1"
  if [ "$1" == "production" ]; then
    # stop_certbot
    docker stop aloes-gw-prod
    docker container rm aloes-gw-prod
  else
    docker stop aloes-gw
    docker container rm aloes-gw
  fi
}

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

  if [ "$SERVICE" == "proxy" ]; then
    stop_proxy $ENV
  else
    local a=$SECONDS
    stop_services $ENV &
    local process_id=$!
    wait $process_id
    local elapsedseconds=$(( SECONDS - a ))
    echo "Stopped services with status $? in $elapsedseconds s"

    a=$SECONDS
    stop_proxy $ENV &
    process_id=$!
    wait $process_id
    elapsedseconds=$(( SECONDS - a ))
    echo "Stopped proxy with status $? in $elapsedseconds s"
  fi

}
