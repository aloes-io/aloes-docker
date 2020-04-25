#!/bin/bash

is_comment() {
  case "$1" in
  \#*)
    # log_verbose "Skip: $1"
    return 0
    ;;
  esac
  return 1
}

is_blank() {
  case "$1" in
  '')
    # log_verbose "Skip: $1"
    return 0
    ;;
  esac
  return 1
}

read_var() {
  if [ -z "$1" ]; then
    echo "environment variable name is required"
    exit 1
  fi

  local ENV_FILE='.env'
  # env_file="$(pwd)/.env"
  if [ ! -z "$2" ]; then
    ENV_FILE="$2"
  fi

  local VAR=$(grep "^$1=" $ENV_FILE | gxargs -d '\n')
  # local VAR=$(grep "^$1=" $ENV_FILE | xargs -d '\n')
  IFS="=" read -ra VAR <<< "$VAR"
  IFS=" "
  # if is_comment "$VAR"; then
  #   return
  # fi
  # if is_blank "$VAR"; then
  #   return
  # fi
  echo ${VAR[1]}
}

check_env() {
  if [ -z "$1" ]; then
    echo "Environment variable name is required"
    exit 1
  fi

  local current_key=$1
  local env_file=$2
  if [ -z "$2" ]; then
    env_file="$(pwd)/.env"
  fi

  local key_exists=""
  grep -q -i "$current_key=" "$env_file"
  if  [ $? == 0 ]; then
    # current_value=$(read_var $current_key $env_file)
    if [ -z "$(read_var $current_key $env_file)" ]; then
      key_exists=""
    else
      key_exists=1
    fi
  fi
  
  # echo "$current_value"
  echo "$key_exists"
}

set_env() {
  if [ -z "$1" ]; then
    echo "Environment variable name is required"
    exit 1
  fi
  if [ -z "$2" ]; then
    echo "Environment variable value is required"
    exit 1
  fi

  local current_key=$1
  local current_value=$2
  local env_file=$3
  if [ -z "$3" ]; then
    env_file="$(pwd)/.env"
  fi

  grep -q -n "$current_key=" $env_file
  if  [ $? == 0 ]; then
    del_env $current_key $env_file
  fi

  echo "$current_key=$current_value" >> "$env_file"
}

del_env() {
  if [ -z "$1" ]; then
    echo "Environment variable name is required"
    exit 1
  fi

  local current_key=$1
  local env_file=$2
  if [ -z "$2" ]; then
    env_file="$(pwd)/.env"
  fi

  sed -i '' "/$current_key=/d" $env_file
}