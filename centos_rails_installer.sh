#!/bin/bash

# MIT License
#
# Copyright (c) 2019 fabio boccacini <fboccacini@gmail.com> ver. 0.1
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


usage() {
  echo "Usage: $0 [-c|--config-only] [-y|--assume-yes] [-u|--system-update <y|n>] [-d|--delete-install-folder <y|n>] [-g|--install-git <y|n>] [-db <mariadb|postgresql>]" 1>&2;
  echo "  -c -config-only: skips installation and goes straight to rails configuration."
  echo "  -y -yes: assume yes to all options exept the ones specified" 1>&2;
  echo "  -n -no: assume no to all options exept the ones specified" 1>&2;
  echo "  -u -update: performs system update at the beginning (default yes)" 1>&2;
  echo "  -r -remove: remove installation folder at the end (default yes)" 1>&2;
  echo "  -d -db: install db (default yes)" 1>&2;
  echo "  -t -type=<mariadb|postgresql>: choose db type, assumes db install: yes. By -y default is MariaDB." 1>&2;
  echo "  -g -git: install git (default yes)" 1>&2;

  exit 1;
}

# Initialize options
UPDATE='x'
DELETE='x'
GIT='x'
DB='x'
CONFIG='x'

set -e

# Get options
while getopts "ynducgt:" o; do
    case "${o}" in
        c)
            CONLY='y'
            ;;

        y)
            ASSUME='y'
            UPDATE='y'
            DELETE='y'
            GIT='y'
            DB='y'
            CONFIG='y'
            if [[ -z "DB_TYPE" ]]
            then
              DB_TYPE='mariadb'
            fi
            ;;

        n)
            ASSUME='n'
            UPDATE='n'
            DELETE='n'
            GIT='n'
            DB='n'
            CONFIG='n'
            ;;

        b)
            if [[ $ASSUME = 'y' ]]
            then
              DB='n'
            else
              DB='y'
            fi
            ;;

        t)
            DB='y'
            DB_TYPE=$OPTARG
            ;;

        g)
            if [[ $ASSUME = 'y' ]]
            then
              GIT='n'
            else
              GIT='y'
            fi
            ;;

        u)
            if [[ $ASSUME = 'y' ]]
            then
              UPDATE='n'
            else
              UPDATE='y'
            fi
            ;;

        d)
            if [[ $ASSUME = 'y' ]]
            then
              DELETE='n'
            else
              DELETE='y'
            fi
            ;;

        *)
            echo "${o}"
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ "$DB_TYPE" != "mariadb" ]] && [[ "$DB_TYPE" != "postgresql" ]]
then
  echo "Unknown DB $DB_TYPE."
  exit 1
fi

echo
echo "+-----------------------------------------------------------------+"
echo "| Ruby-on-Rails interactive installer                             |"
echo "|                                                                 |"
echo "| RVM, Nginx, Passenger, bundler, MariaDB/Postgresql and git      |"
echo "|                                                                 |"
echo "| Please have the following informations handy:                   |"
echo "| Project name                                                    |"
echo "| Git account credentials, local web server user credentials,     |"
echo "| DB user credentials                                             |"
echo "+-----------------------------------------------------------------+"
echo
echo

# Get starting path to get back after execution
STARTING_PATH=$(pwd)

# Get installer path to call specific scripts
ABS_PATH=$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")
INSTALLER_PATH=$(dirname $ABS_PATH)

# Set user (get to sudo alread -sy so it won't ask later)
sudo echo -n "What user should execute the webserver (we'll create one if it doesn't exist)?  "
read NEW_USER

# Disable stop on error in case the id command fails
set +e
id -u $NEW_USER > /dev/null 2>&1

if [ $? -eq 0 ]
then
  # Re-enable stop on error
  set -e
  echo
  echo "Ok, we'll use $NEW_USER."
  echo
else
  # Re-enable stop on error
  set -e
  echo
  echo "Adding user: $NEW_USER.."

  NEW_PASSWD_RETYPED='ssdasd'

  while [[ "$NEW_PASSWD" != "$NEW_PASSWD_RETYPED" ]]
  do
    echo -n "Password:"
    read -s NEW_PASSWD
    echo
    echo -n "Retype it:"
    read -s NEW_PASSWD_RETYPED

  done

  sudo useradd -m $NEW_USER
  echo $NEW_PASSWD | sudo passwd $NEW_USER --stdin
  echo "User $NEW_USER created."
  echo
fi

# Add new user to the sudoers
sudo usermod -a -G wheel $NEW_USER
echo
# If it's a virtualbox vm add the user to vboxsf group too
if grep -q vboxsf /etc/group
then
  echo "Adding vboxsf group to $NEW_USER."
  sudo usermod -a -G vboxsf $NEW_USER
  sudo groups $NEW_USER
  echo
fi

# If config only option was selected go straight to configuration
if [[ $CONLY == 'y' ]]
then

  sudo -iu $NEW_USER bash $INSTALLER_PATH/scripts/configure-rails.sh $DB_TYPE
  echo
  exit

fi

# Perform system update
while [[ $UPDATE != "y" ]] && [[ $UPDATE != "n" ]] && [[ $UPDATE != "Y" ]] && [[ $UPDATE != "N" ]] && [[ $UPDATE != '' ]]
do
  echo -n "Proceed with system update? [Y/n]  "
  read UPDATE
  echo
done

if [[ $UPDATE = "y" ]] || [[ $UPDATE = "Y" ]] || [[ $UPDATE = '' ]]
then

  # Update the system
  bash $INSTALLER_PATH/scripts/update.sh

else
  echo "System update skipped."
  echo
fi


# Enable epel
echo "Enabling EPEL.."
echo
sudo yum -y --enablerepo=extras install epel-release
echo

echo "Installing dependencies.."
sudo yum -y install openssl openssl-devel subversion curl curl-devel gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel  make bzip2 autoconf automake libtool bison sqlite-devel libxml2 libxml2-devel libxslt libxslt-devel libtool gnupg mlocate
echo

echo -n "Would you like to install git? [Y/n]  "
while [[ $GIT != 'y' ]] && [[ $GIT != 'n' ]] && [[ $GIT != 'Y' ]] && [[ $GIT != 'N' ]] && [[ $GIT != '' ]]
do

  read GIT
done

if [[ $GIT = 'y' ]] || [[ $GIT = 'Y' ]] || [[ $GIT = '' ]]
then

  # Install git
  bash $INSTALLER_PATH/scripts/git-install.sh

else
  echo "Git installation skipped."
  echo
fi



# Create a folder to contain all needed packages
mkdir -p installation
sudo chmod 777 installation

echo

cd installation
INST_DIR=$(pwd)

while [[ $DB != 'y' ]] && [[ $DB != 'n' ]] && [[ $DB != 'Y' ]] && [[ $DB != 'N' ]] && [[ $DB != '' ]]
do
  echo -n "Would you like to use or install a local db server? [Y/n]  "
  read DB
done

if [[ $DB = 'y' ]] || [[ $DB = 'Y' ]] || [[ $DB = '' ]]
then
  if [[ $DB_TYPE != 'mariadb' ]] && [[ $DB_TYPE != 'postgresql' ]]
  then
    # DB choice
    while [[ $CHOICE != '1' ]] && [[ $CHOICE != '2' ]]
    do
      echo "Which DB server would you like to install?"
      echo "    1 - MariaDB"
      echo "    2 - Postgresql"
      read CHOICE
    done

    case "${CHOICE}" in

    2)

      # Install Postgresql server
      DB_TYPE=postgresql
      ;;

    *)

      # Install MariaDB server
      DB_TYPE=mariadb
      ;;

    esac
  fi

  case "${DB_TYPE}" in

  postgresql)

    # Install Postgresql server
    bash $INSTALLER_PATH/scripts/postgres-install.sh $ASSUME
    ;;

  mariadb)

    # Install MariaDB server
    bash $INSTALLER_PATH/scripts/mariadb-install.sh $ASSUME
    ;;

  esac

fi

if [[ $NEW_USER != $(whoami) ]]
then

# Change user to install gem in it's path
echo "Becoming $NEW_USER to install packages:"

fi

# Install RVM and Ruby
sudo -iu $NEW_USER bash $INSTALLER_PATH/scripts/rvm-ruby-install.sh

# Install rails, passenger and nginx
sudo -iu $NEW_USER bash $INSTALLER_PATH/scripts/rails-passenger-nginx-install.sh

cd $STARTING_PATH
echo
echo "Finished!"
echo
echo "Installation directory: $INST_DIR"
ls $INST_DIR

while [[ $DELETE != 'y' ]] && [[ $DELETE != 'n' ]] && [[ $DELETE != 'Y' ]] && [[ $DELETE != 'N' ]] && [[ $DELETE != '' ]]
do
  echo -n "You won't probably need it anymore, would you like to delete it? (Y/n)"
  read DELETE
done

if [[ $DELETE = 'y' ]] || [[ $DELETE = 'Y' ]] || [[ $DELETE = '' ]]
then
  rm -rf $INST_DIR
  echo "Alright, folder deleted."
  echo
else
  echo "Alright, deletion skipped."
  echo
fi

while [[ $CONFIG != 'y' ]] && [[ $CONFIG != 'n' ]] && [[ $CONFIG != 'Y' ]] && [[ $CONFIG != 'N' ]] && [[ $CONFIG != '' ]]
do
  echo
  echo -n "Finally, do you want configure rails as well? [Y/n]"
  read CONFIG
  echo
done

if [[ $CONFIG = 'y' ]] || [[ $CONFIG = 'Y' ]] || [[ $CONFIG = '' ]]
then
  sudo -iu $NEW_USER bash $INSTALLER_PATH/scripts/configure-rails.sh $DB_TYPE
  echo "Ok, all done. Have a nice developing day!"
  echo
else
  echo "Ok, don't forget to configure it manually then. Have a nice developing day!"
  echo
fi
