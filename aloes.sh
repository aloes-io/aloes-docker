#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/helpers/build.sh"
. "$DIR/helpers/create.sh"
. "$DIR/helpers/delete.sh"
. "$DIR/helpers/env-parser.sh"
. "$DIR/helpers/generate-uuid.sh"
. "$DIR/helpers/log.sh"
. "$DIR/helpers/start.sh"
. "$DIR/helpers/stop.sh"
. "$DIR/helpers/pull.sh"
. "$DIR/helpers/letsencrypt-init.sh"

usage() {
	echo "Usage $0 -c command_name -e env_name
Commands : 
	- create
	- build
	- start
	- stop
	- pull
	- log
  "
}

get_env_name() {
  if [ "$1" == "production" ]; then
    ENV="production"
  elif [ "$1" == "local" ]; then
    ENV="local"
  else
    ENV="local"
  fi
  echo ${ENV}
}

get_mac_address() {
	local mac_address
	local interface
	if [ -z "$1" ]; then
		# interface=eth0
		interface=en1
	else 
		interface=$1
	fi
	
	if [ -f "/sys/class/net/$interface/address" ]; then
		mac_address=$(cat /sys/class/net/$interface/address)
	elif [ -f "/sys/class/net/eth0/address" ]; then
		mac_address=$(cat /sys/class/net/eth0/address)
	elif [ -f "/sys/class/net/wlan0/address" ]; then
		mac_address=$(cat /sys/class/net/wlan0/address)
	elif [ -f "/sys/class/net/wlp2s0/address" ]; then
		mac_address=$(cat /sys/class/net/wlp2s0/address)
	else
		mac_address=$(ifconfig $interface | awk '/ether/{print $2}')
	fi

	echo $mac_address
}

get_uuid() {
	local mac_address=$(get_mac_address)
	local uuid
	if [[ -z "$mac_address" ]]; then 
		echo "No MAC address retrieved"
		exit 1
	elif [ -x "$(command -v uuidgen)" ]; then
		uuid=$(uuidgen)
	else 
		uuid=$(generate 4 $mac_address)
	fi

	echo $uuid
}

is_valid_command() {
  case "$1" in
		'create')
      return 0
      ;;
    'build')
      return 0
      ;;
    'start')
      return 0
      ;;
		'stop')
      return 0
      ;;
    'pull')
      return 0
      ;;
    'log')
      return 0
    ;; 
  esac
  return 1
}

# echo LOGO, NAME
# COPYRIGHTS LICENSE
# DESCRIPTION

# if no argument passed, prompt user to get command and environment
if [ -z "$1" ]; then
	echo "Type the command you want to execute (create|build|start|stop|pull|log), followed by [ENTER]:"
	read CMD
	if is_valid_command "$CMD"; then
    echo "Type the environment used to execute $CMD (local|production), followed by [ENTER]:"
		read ENV
	else
    usage
    exit 1
	fi
fi

# else parse arguments from CLI
while [[ $# > 1 ]]
do
key="$1"

case $key in
  -c|--command)
      CMD="$2"
      if ! is_valid_command "$CMD"; then 
        usage
        exit 1
      else
        shift
      fi
      ;;
  -e|--env)
      ENV="$2"
      shift
      ;;
  -s|--service)
      SERVICE="$2"
      shift
      ;;
  *)
    usage
    exit 1
    ;;
esac
shift # past argument or value
done

ENV=$(get_env_name ${ENV})
SECONDS=0

if [ "$CMD" == "build" ]; then
	echo "$CMD containers for $ENV environment"
	build $ENV $SERVICE
elif [ "$CMD" == "start" ]; then
	echo "$CMD $ENV containers"
	start $ENV $SERVICE
elif [ "$CMD" == "stop" ]; then
	echo "$CMD $ENV containers"
	stop $ENV $SERVICE
elif [ "$CMD" == "log" ]; then
	echo "$CMD $ENV services"
	log $ENV $SERVICE
elif [ "$CMD" == "create" ]; then
	create $ENV
    # read -p "Would you like to build your project now ? (y/N) " answer
elif [ "$CMD" == "pull" ]; then
	echo "$CMD $ENV containers"
	pull $ENV $SERVICE
elif [ "$CMD" == "delete" ]; then
	echo "$CMD containers for $ENV environment"
	# not working yet
	delete $ENV
else
	echo "Invalid command"
	usage
	exit 1
fi

