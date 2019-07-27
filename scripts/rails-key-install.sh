#!/bin/bash
set -e

#cd project_path

ENV_VARS=$1
SECRET_KEY=$(rake secret)

if [[ $ENV_VARS == 'y' ]] || [[ $ENV_VARS == 'Y' ]]
then

  echo "Creating ENV VARS.."
  echo "RAILS_KEY_BASE=$SECRET_KEY" | sudo tee -a /etc/profile > /dev/null
  set +e
  if [ -z $(ls config/secrets.yml 2>/dev/null) ]
  then
    set -e
    SECS=<<EOF
development:
  secret_key_base: <%= ENV['RAILS_KEY_BASE'] %>

test:
  secret_key_base: <%= ENV['RAILS_KEY_BASE'] %>

production:
  secret_key_base: <%= ENV['RAILS_KEY_BASE'] %>

EOF
    echo $SECS > config/secrets.yml
  else
    set -e
    sed -i "s/\(secret_key_base:[\t ]*\)/\1<%= ENV['RAILS_KEY_BASE'] %>/g" config/secrets.yml
  fi

else

  set +e
  if [ -z $(ls config/secrets.yml 2>/dev/null) ]
  then
    set -e
    PRO=$(rake secrets)
    TEST=$(rake secrets)
    DEV=$(rake secrets)
    SECS=<<EOF
development:
  secret_key_base: $DEV

test:
  secret_key_base: $TEST

production:
  secret_key_base: $DEV

  EOF
    echo $SECS > config/secrets.yml
  else
    set -e
    sed -i "s/\(secret_key_base:[\t ]*\)/\1$(rake secrets)/g" config/secrets.yml
  fi

fi
