#!/bin/bash

get_value_from_user() {
	if [ -z "$1" ]; then
    echo "Environment variable name is required"
    exit 1
  fi

  local current_key=$1
  local env_file=$2
  local from_env=$3

  local variable_default=""
  if [ "$from_env" == "1" ]; then 
    if [ -z "$env_file" ]; then
      env_file="$(pwd).env"
    fi
    if [ ! -f "$env_file" ]; then
      echo "Env file $env_file does not exit"
      exit 1
    fi
    local key_exists=$(check_env $current_key $env_file)
    if  [ $key_exists != "0" ]; then
      variable_default=$(read_var $current_key $env_file)
    fi
    # grep -q -i "$current_key=" "$env_file"
    # if  [ $? == 0 ]; then
    #   variable_default=$(read_var $current_key $env_file)
    # fi
  fi
  if [ -z "$variable_default" ]; then
    variable_default=$(read_var $current_key .env.sample)
  fi

	echo -n "$current_key (default=$variable_default) :"
	read USER_VAL
	if [ -z "$USER_VAL" ]; then 
		USER_VAL=$variable_default 
	fi

  if [ "$from_env" == "1" ]; then
    del_env $current_key $env_file
  fi
}

create_device_manager_env() {
  if [ -z "$1" ]; then
    echo "Config file name is required"
    exit 1
  fi
  local config=$1
  
  local ENV=$2
  local HTTP_SERVER_URL
  local HTTP_CLIENT_URL
  if [ "$ENV" == "production" ]; then
    HTTP_SERVER_URL=$(read_var PROXY_HTTPS_SERVER_URL $config)
    HTTP_CLIENT_URL=$(read_var PROXY_HTTPS_CLIENT_URL $config)
  else
    HTTP_SERVER_URL=$(read_var PROXY_HTTP_SERVER_URL $config)
    HTTP_CLIENT_URL=$(read_var PROXY_HTTP_CLIENT_URL $config)
  fi

  local aloes_config="$(pwd)/config/device-manager/.env"
  if [ -f "$aloes_config" ]; then
    rm $aloes_config
  fi

  echo "NODE_ENV=$(read_var NODE_ENV $config)
NODE_NAME=$(read_var APP_NAME $config)
ALOES_ID=$(read_var ALOES_ID $config)
ALOES_KEY=$(read_var ALOES_KEY $config)
ADMIN_EMAIL=$(read_var ADMIN_EMAIL $config)
CONTACT_EMAIL=hey@aloes.io
DOMAIN=$(read_var PROXY_DOMAIN $config)
HTTP_SERVER_URL=$HTTP_SERVER_URL
HTTP_CLIENT_URL=$HTTP_CLIENT_URL
HTTP_SERVER_HOST=0.0.0.0
HTTP_SERVER_PORT=$(read_var HTTP_SERVER_PORT $config)
HTTP_SECURE=$(read_var HTTP_SECURE $config)
HTTP_TRUST_PROXY=$(read_var HTTP_TRUST_PROXY $config)
REST_API_ROOT=$(read_var REST_API_ROOT $config)
COOKIE_SECRET=$(read_var COOKIE_SECRET $config)
MQTT_BROKER_URL=$(read_var PROXY_MQTT_BROKER_URL $config)
MQTT_BROKER_PORT=$(read_var MQTT_BROKER_PORT $config)
MQTTS_BROKER_URL=$(read_var PROXY_MQTTS_BROKER_URL $config)
MQTT_SECURE=$(read_var MQTT_SECURE $config)
MQTT_TRUST_PROXY=$(read_var MQTT_TRUST_PROXY $config)
MQTTS_SELF_SIGNED_CERT=$(read_var MQTTS_SELF_SIGNED_CERT $config)
WS_BROKER_PORT=$(read_var WS_BROKER_PORT $config)
SERVER_LOGGER_LEVEL=$(read_var SERVER_LOGGER_LEVEL $config)
SMTP_HOST=$(read_var SMTP_HOST $config)
SMTP_PORT=$(read_var SMTP_PORT $config)
SMTP_SECURE=$(read_var SMTP_SECURE $config)
SMTP_USER=$(read_var SMTP_USER $config)
SMTP_PASS=$(read_var SMTP_PASS $config)
MONGO_HOST=$(read_var MONGO_HOST $config)
MONGO_PORT=$(read_var MONGO_PORT $config)
MONGO_COLLECTION=$(read_var MONGO_COLLECTION $config)
MONGO_USER=$(read_var MONGO_USER $config)
MONGO_PASS=$(read_var MONGO_PASS $config)
REDIS_HOST=$(read_var REDIS_HOST $config)
REDIS_PORT=$(read_var REDIS_PORT $config)
REDIS_MQTT_PERSISTENCE=$(read_var REDIS_MQTT_PERSISTENCE $config)
REDIS_MQTT_EVENTS=$(read_var REDIS_MQTT_EVENTS $config)
REDIS_COLLECTIONS=$(read_var REDIS_COLLECTIONS $config)
REDIS_PASS=$(read_var REDIS_PASS $config)
INFLUXDB_PROTOCOL=http
INFLUXDB_HOST=$(read_var INFLUXDB_HOST $config)
INFLUXDB_PORT=$(read_var INFLUXDB_PORT $config)
INFLUXDB_DB=$(read_var INFLUXDB_DB $config)
INFLUXDB_USER=$(read_var INFLUXDB_USER $config)
INFLUXDB_USER_PASSWORD=$(read_var INFLUXDB_USER_PASSWORD $config)
OCD_API_KEY=$(read_var OCD_API_KEY $config)
EXTERNAL_TIMER=$(read_var EXTERNAL_TIMER $config)
TIMER_SERVER_URL=$(read_var TIMER_SERVER_URL $config)
FS_PATH=./storage
GITHUB_CLIENT_ID_LOGIN=$(read_var GITHUB_CLIENT_ID_LOGIN $config)
GITHUB_CLIENT_SECRET_LOGIN=$(read_var GITHUB_CLIENT_SECRET_LOGIN $config)
GITHUB_CLIENT_ID_LINK=$(read_var GITHUB_CLIENT_ID_LINK $config)
GITHUB_CLIENT_SECRET_LINK=$(read_var GITHUB_CLIENT_SECRET_LINK $config)
GIT_REPO_SSH_URL=git@framagit.org:aloes/device-manager.git
INSTANCES_COUNT=1" >> "$aloes_config"
}

# replicate_env() {
  # using an .env.template ?
  # envsubst '$${NODE_ENV},$${APP_NAME},$${ALOES_ID},$${ALOES_KEY},$${NODE_ENV},$${APP_NAME},$${ADMIN_EMAIL},$${CONTACT_EMAIL},$${HTTP_SERVER_PORT},$${HTTP_SECURE},\
  # $${HTTP_TRUST_PROXY},$${REST_API_ROOT},$${COOKIE_SECRET},$${WS_BROKER_PORT},$${MQTT_BROKER_PORT},$${MQTT_SECURE},$${MQTT_TRUST_PROXY},$${SERVER_LOGGER_LEVEL},\
  # $${SMTP_HOST},$${SMTP_PORT},$${SMTP_SECURE},$${SMTP_USER},$${SMTP_PASS},\
  # $${MONGO_HOST},$${MONGO_PORT},$${MONGO_COLLECTION},$${MONGO_ADMIN_USERNAME},$${MONGO_ADMIN_PASSWORD},$${MONGO_USER},$${MONGO_PASS},\
  # $${REDIS_HOST},$${REDIS_PORT},$${REDIS_MQTT_PERSISTENCE},$${REDIS_MQTT_EVENTS},$${REDIS_COLLECTIONS},$${REDIS_PASS},\
  # $${INFLUXDB_HOST},$${INFLUXDB_PORT},$${INFLUXDB_DB},$${INFLUX_ADMIN_ENABLED},$${INFLUX_ADMIN_USER},$${INFLUX_ADMIN_PASSWORD},$${INFLUXDB_USER},$${INFLUXDB_USER_PASSWORD},\
  # $${OCD_API_KEY},$${EXTERNAL_TIMER},$${TIMER_SERVER_URL},$${TIMER_SERVER_PORT},\
  # $${GITHUB_CLIENT_ID_LOGIN},$${GITHUB_CLIENT_SECRET_LOGIN},$${GITHUB_CLIENT_ID_LINK},$${GITHUB_CLIENT_SECERT_LINK},$${GIT_REPO_SSH_URL}\
  # $${LB_SERVER_HOST},$${LB_HTTP_SERVER_PORT},$${LB_TCP_SERVER_PORT},\
  # $${PROXY_SERVER_HOST},$${PROXY_DOMAIN},$${PROXY_EXTENSION},$${PROXY_IP},$${PROXY_HTTP_CLIENT_URL},$${PROXY_HTTPS_CLIENT_URL},$${PROXY_HTTP_SERVER_PORT},\
  # $${PROXY_HTTP_SERVER_URL},$${PROXY_HTTPS_SERVER_PORT},$${PROXY_HTTPS_SERVER_URL},$${PROXY_WS_BROKER_URL},$${PROXY_WSS_BROKER_URL}\
  # $${PROXY_MQTT_BROKER_PORT},$${PROXY_MQTT_BROKER_URL},$${PROXY_MQTTS_BROKER_PORT},$${PROXY_MQTTS_BROKER_URL}' <  "$(pwd)/.env.template" > "$to" 
# }

replicate_env() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Config filenames are required"
    exit 1
  fi

  local from=$1
  local to="$2"
  if [ -f "$to" ]; then
    rm $to
  fi

  local ENV=$3
  local HTTP_SERVER_URL
  local HTTP_CLIENT_URL
  local WS_BROKER_URL
  if [ "$ENV" == "production" ]; then
    HTTP_SERVER_URL=$(read_var PROXY_HTTPS_SERVER_URL $from)
    WS_BROKER_URL=$(read_var PROXY_WSS_BROKER_URL $from)
    HTTP_CLIENT_URL=$(read_var PROXY_HTTPS_CLIENT_URL $from)
    PROXY_CONFIG_TEMPLATE=aloes-lb-production.template
  else
    HTTP_SERVER_URL=$(read_var PROXY_HTTP_SERVER_URL $from)
    WS_BROKER_URL=$(read_var PROXY_WS_BROKER_URL $from)
    HTTP_CLIENT_URL=$(read_var PROXY_HTTP_CLIENT_URL $from)
    PROXY_CONFIG_TEMPLATE=aloes-lb.template
  fi

  echo "# ALOES API CONFIG
NODE_ENV=$(read_var NODE_ENV $from)
APP_NAME=$(read_var APP_NAME $from)
ALOES_ID=$(read_var ALOES_ID $from)
ALOES_KEY=$(read_var ALOES_KEY $from)
ADMIN_EMAIL=$(read_var ADMIN_EMAIL $from)
CONTACT_EMAIL=hey@aloes.io
HTTP_SERVER_PORT=$(read_var HTTP_SERVER_PORT $from)
HTTP_SECURE=$(read_var HTTP_SECURE $from)
HTTP_TRUST_PROXY=$(read_var HTTP_TRUST_PROXY $from)
REST_API_ROOT=$(read_var REST_API_ROOT $from)
COOKIE_SECRET=$(read_var COOKIE_SECRET $from)
WS_BROKER_PORT=$(read_var WS_BROKER_PORT $from)
MQTT_BROKER_PORT=$(read_var MQTT_BROKER_PORT $from)
MQTT_SECURE=$(read_var MQTT_SECURE $from)
MQTT_TRUST_PROXY=$(read_var MQTT_TRUST_PROXY $from)
SERVER_LOGGER_LEVEL=$(read_var SERVER_LOGGER_LEVEL $from)
# ALOES GRAPHQL API CONFIG
GRAPHQL_SERVER_PATH=$(read_var GRAPHQL_SERVER_PATH $from)
GRAPHQL_HTTP_SERVER_PORT=$(read_var GRAPHQL_HTTP_SERVER_PORT $from)
GRAPHQL_WS_SERVER_PORT=$(read_var GRAPHQL_WS_SERVER_PORT $from)
# VUE APP CONFIG
VUE_APP_SERVER_URL=$HTTP_SERVER_URL 
VUE_APP_BROKER_URL=$WS_BROKER_URL
VUE_APP_CLIENT_URL=$HTTP_CLIENT_URL 
# SMTP CONFIG
SMTP_HOST=$(read_var SMTP_HOST $from)
SMTP_PORT=$(read_var SMTP_PORT $from)
SMTP_SECURE=$(read_var SMTP_SECURE $from)
SMTP_USER=$(read_var SMTP_USER $from)
SMTP_PASS=$(read_var SMTP_PASS $from)
# MONGODB CONFIG
MONGO_HOST=$(read_var MONGO_HOST $from)
MONGO_PORT=$(read_var MONGO_PORT $from)
MONGO_COLLECTION=$(read_var MONGO_COLLECTION $from)
MONGO_ADMIN_USERNAME=$(read_var MONGO_ADMIN_USERNAME $from)
MONGO_ADMIN_PASSWORD=$(read_var MONGO_ADMIN_PASSWORD $from)
MONGO_USER=$(read_var MONGO_USER $from)
MONGO_PASS=$(read_var MONGO_PASS $from)
# REDIS CONFIG
REDIS_HOST=$(read_var REDIS_HOST $from)
REDIS_PORT=$(read_var REDIS_PORT $from)
REDIS_MQTT_PERSISTENCE=$(read_var REDIS_MQTT_PERSISTENCE $from)
REDIS_MQTT_EVENTS=$(read_var REDIS_MQTT_EVENTS $from)
REDIS_COLLECTIONS=$(read_var REDIS_COLLECTIONS $from)
REDIS_PASS=$(read_var REDIS_PASS $from)
# INFLUXDB CONFIG
INFLUXDB_HOST=$(read_var INFLUXDB_HOST $from)
INFLUXDB_PORT=$(read_var INFLUXDB_PORT $from)
INFLUXDB_DB=$(read_var INFLUXDB_DB $from)
INFLUX_ADMIN_ENABLED=$(read_var INFLUX_ADMIN_ENABLED $from)
INFLUX_ADMIN_USER=$(read_var INFLUX_ADMIN_USER $from)
INFLUX_ADMIN_PASSWORD=$(read_var INFLUX_ADMIN_PASSWORD $from)
INFLUXDB_USER=$(read_var INFLUXDB_USER $from)
INFLUXDB_USER_PASSWORD=$(read_var INFLUXDB_USER_PASSWORD $from)
# OPEN CAGE CONFIG
OCD_API_KEY=$(read_var OCD_API_KEY $from)
# TIMER CONFIG
EXTERNAL_TIMER=$(read_var EXTERNAL_TIMER $from)
TIMER_SERVER_URL=$(read_var TIMER_SERVER_URL $from)
# GITHUB CONFIG
GITHUB_CLIENT_ID_LOGIN=$(read_var GITHUB_CLIENT_ID_LOGIN $from)
GITHUB_CLIENT_SECRET_LOGIN=$(read_var GITHUB_CLIENT_SECRET_LOGIN $from)
GITHUB_CLIENT_ID_LINK=$(read_var GITHUB_CLIENT_ID_LINK $from)
GITHUB_CLIENT_SECRET_LINK=$(read_var GITHUB_CLIENT_SECRET_LINK $from)
GIT_REPO_SSH_URL=git@framagit.org:aloes/aloes-docker.git
# PROXY CONFIG
PROXY_SERVER_HOST=$(read_var PROXY_SERVER_HOST $from)
PROXY_DOMAIN=$(read_var PROXY_DOMAIN $from)
PROXY_EXTENSION=$(read_var PROXY_EXTENSION $from)
PROXY_IP=$(read_var PROXY_IP $from)
PROXY_CONFIG_TEMPLATE=$PROXY_CONFIG_TEMPLATE
PROXY_HTTP_CLIENT_URL=$(read_var PROXY_HTTP_CLIENT_URL $from)
PROXY_HTTPS_CLIENT_URL=$(read_var PROXY_HTTPS_CLIENT_URL $from)
PROXY_HTTP_SERVER_PORT=$(read_var PROXY_HTTP_SERVER_PORT $from)
PROXY_HTTP_SERVER_URL=$(read_var PROXY_HTTP_SERVER_URL $from)
PROXY_HTTPS_SERVER_PORT=$(read_var PROXY_HTTPS_SERVER_PORT $from)
PROXY_HTTPS_SERVER_URL=$(read_var PROXY_HTTPS_SERVER_URL $from)
PROXY_MQTT_BROKER_PORT=$(read_var PROXY_MQTT_BROKER_PORT $from)
PROXY_MQTT_BROKER_URL=$(read_var PROXY_MQTT_BROKER_URL $from)
PROXY_MQTTS_BROKER_PORT=$(read_var PROXY_MQTTS_BROKER_PORT $from)
PROXY_MQTTS_BROKER_URL=$(read_var PROXY_MQTTS_BROKER_URL $from)
PROXY_WS_BROKER_URL=$(read_var PROXY_WS_BROKER_URL $from)
PROXY_WSS_BROKER_URL=$(read_var PROXY_WSS_BROKER_URL $from)" >> "$to"
}

create_env() {
  if [ -z "$1" ]; then
    echo "Environment name is required to build services"
    exit 1
  fi

  local ENV=$1
  local config="$(pwd)/.env"
  local config_tmp="$(pwd)/.env.tmp"
  local ALOES_ID
  local ALOES_KEY
  local from_env=0
  # config="$(pwd)/.env.$ENV"

  if [ -f "$config_tmp" ]; then
    rm $config_tmp
  fi

  # set NODE_ENV manually ?
  if [ -f "$config" ]; then
    read -p "Config file exists, continue and override ? (y/N) " answer
    if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
      read -p "Use current configuration as a template ? (y/N) " answer
      if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
        cp $config $config_tmp
        from_env=1
        local key_exists=$(check_env ALOES_ID $config_tmp)
        if [ -z "$key_exists" ]; then
          ALOES_ID=$(get_uuid)
          set_env ALOES_ID $ALOES_ID $config_tmp
        else
          ALOES_ID=$(read_var ALOES_ID $config_tmp)
        fi

        key_exists=$(check_env ALOES_KEY $config_tmp)
        if [ -z "$key_exists" ]; then
          ALOES_KEY=$(get_uuid)
          set_env ALOES_KEY $ALOES_KEY $config_tmp
        else
          ALOES_KEY=$(read_var ALOES_KEY $config_tmp)
        fi

        # del_env NODE_ENV $config_tmp
      else
        ALOES_ID=$(get_uuid)
        ALOES_KEY=$(get_uuid)
        # NODE_ENV=$ENV
        set_env ALOES_ID $ALOES_ID $config_tmp
        set_env ALOES_KEY $ALOES_KEY $config_tmp
      fi
    else 
      exit
    fi
  fi
  # set_env NODE_ENV $NODE_ENV $config_tmp
  local env_keys

  read -p "Would you like to configure Aloes REST and Async API ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    # INSTANCES_COUNT=1
    # INSTANCES_PREFIX=
    env_keys=(NODE_ENV APP_NAME HTTP_SERVER_PORT MQTT_BROKER_PORT HTTP_TRUST_PROXY WS_BROKER_PORT 
      MQTT_TRUST_PROXY REST_API_ROOT SERVER_LOGGER_LEVEL ADMIN_EMAIL)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure Aloes GraphQL API ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(GRAPHQL_SERVER_PATH GRAPHQL_HTTP_SERVER_PORT GRAPHQL_WS_SERVER_PORT)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  # todo set default PROXY_IP based on machine ip ?
  read -p "Would you like to configure Nginx proxy ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(PROXY_SERVER_HOST PROXY_HTTP_SERVER_PORT PROXY_MQTT_BROKER_PORT PROXY_HTTP_CLIENT_URL 
      PROXY_HTTP_SERVER_URL PROXY_WS_BROKER_URL PROXY_MQTT_BROKER_URL PROXY_IP PROXY_DOMAIN 
      PROXY_EXTENSION)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done

    if [ "$ENV" == "production" ]; then
      if [ "$from_env" == "1" ]; then
        del_env HTTP_SECURE $config_tmp
        del_env MQTT_SECURE $config_tmp
      fi
      set_env HTTP_SECURE true $config_tmp
      set_env MQTT_SECURE true $config_tmp
      echo "Now configure Nginx proxy ssl"
      env_keys=(PROXY_HTTPS_SERVER_PORT PROXY_MQTTS_BROKER_PORT PROXY_HTTPS_CLIENT_URL 
        PROXY_HTTPS_SERVER_URL PROXY_WSS_BROKER_URL PROXY_MQTTS_BROKER_URL)
      for env_key in "${env_keys[@]}"; do
        get_value_from_user $env_key $config_tmp $from_env
        set_env $env_key $USER_VAL $config_tmp
      done
    else
      if [ "$from_env" == "1" ]; then
        del_env HTTP_SECURE $config_tmp
        del_env MQTT_SECURE $config_tmp
      fi
      set_env HTTP_SECURE "" $config_tmp
      set_env MQTT_SECURE "" $config_tmp
    fi
  fi


  read -p "Would you like to configure external timer ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    if [ "$from_env" == "1" ]; then
      del_env EXTERNAL_TIMER $config_tmp
    fi
    set_env EXTERNAL_TIMER true $config_tmp
    env_keys=(TIMER_SERVER_URL)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  # else
  #   if [ "$from_env" == "1" ]; then
  #     del_env EXTERNAL_TIMER $config_tmp
  #   fi
  #   set_env EXTERNAL_TIMER "" $config_tmp
  fi

  read -p "Would you like to configure MongoDB container ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(MONGO_HOST MONGO_PORT MONGO_COLLECTION MONGO_ADMIN_USERNAME MONGO_ADMIN_PASSWORD
      MONGO_USER MONGO_PASS)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure Redis container ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(REDIS_HOST REDIS_PORT REDIS_PASS REDIS_MQTT_PERSISTENCE REDIS_MQTT_EVENTS REDIS_COLLECTIONS)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure InfluxDB container ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(INFLUXDB_HOST INFLUXDB_PORT INFLUXDB_DB INFLUX_ADMIN_ENABLED INFLUX_ADMIN_USER 
      INFLUX_ADMIN_PASSWORD INFLUXDB_USER INFLUXDB_USER_PASSWORD)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure SMTP email provider ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(SMTP_HOST SMTP_PORT SMTP_SECURE SMTP_USER SMTP_PASS)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure OpenCageAPI key ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(OCD_API_KEY)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  read -p "Would you like to configure Github auth provider ? (y/N) " answer
  if [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
    env_keys=(GITHUB_CLIENT_ID_LOGIN GITHUB_CLIENT_SECRET_LOGIN GITHUB_CLIENT_ID_LINK 
      GITHUB_CLIENT_SECRET_LINK)
    for env_key in "${env_keys[@]}"; do
      get_value_from_user $env_key $config_tmp $from_env
      set_env $env_key $USER_VAL $config_tmp
    done
  fi

  replicate_env $config_tmp $config $ENV
  echo "Configuration saved in $config"
  rm $config_tmp
  
  create_device_manager_env $config $ENV
  echo "Configuration replicated in device-manager"

}

init_project () {
  if [ -z "$1" ]; then
    echo "Environment variable name is required to init project"
    exit 1
  fi

  local ENV=$1
  local env_file="$(pwd)/.env"

  a=$SECONDS
  # build local $env_file &
  build $ENV $env_file &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  echo "Built services with status $? in $elapsedseconds s"
  if [ $? == 1 ]; then exit 1 ; fi

  a=$SECONDS
  local DOMAIN=$(read_var PROXY_SERVER_HOST $env_file)
  local ADMIN_EMAIL=$(read_var ADMIN_EMAIL $env_file)
  local data_path="$(pwd)/config/certbot"
  if [ -d "$data_path" ]; then
    read -p "Existing data found for $DOMAIN. Continue and replace existing certificate? (y/N) " answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
      exit
    fi
  fi
  
  # export PROXY_CONFIG_TEMPLATE=aloes-lb.template
  init_ssl $DOMAIN $ADMIN_EMAIL $ENV &
  # init_ssl "$DOMAIN www.$DOMAIN" $ADMIN_EMAIL &
  process_id=$!
  wait $process_id
  elapsedseconds=$(( SECONDS - a ))
  # unset PROXY_CONFIG_TEMPLATE
  echo "Created ssl certificates with status $? in $elapsedseconds s"
  if [ "$?" != "0" ]; then exit 1 ; fi

}

create() {
  if [ -z "$1" ]; then
    echo "Environment variable name is required to create project"
    exit 1
  fi

  local ENV=$1

  echo "Welcome to Aloes creation helper, you will start by creating your .env file.
When prompted type your answer, followed by [ENTER]"
  sleep 1
  create_env $ENV

  # todo add a function to create A and AAAA DNS redirection at domain provider ?

  read -p "Would you like to generate ssl certificates now ? (y/N) " answer
  if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
    exit
  else
    echo "Building services ..."
    init_project $ENV
  fi

  if [ $? -ne 0 ]; then
    echo "Aloes environment creation cancelled"
  fi
}