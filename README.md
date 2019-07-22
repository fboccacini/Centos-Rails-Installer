Centos Rails Installer
======================
Rails interactive installer for CentOS Linux, with Passenger and Nginx.

It drives you from a fresh installed CentOS machine to a fully configured Rails installation. Well, it works on existent machines too, but you know, everything could happen with unknown configurations.. ;)

Precisely it does the following:

- Add a user for the project. It will install all the gems in its own home directory and it will run Nginx. If the specified user exists already it will be used for this purpose. If the script detects a VirtualBox VM environment, the user will also be added the the vboxsf group, so that it can access shared folders.
- System update (optional)
- EPEL enable
- Dependencies installation
- Git installation (optional)
- Local DB installation (optonal). You can choose between MariaDB and Postgresql.
- Rvm and Ruby installation. It will choose the stable Ruby version
- Rails and Passenger gems installation
- Nginx with Passenger compile. It will also configure the service to start it.
- Git clone from an existing repository (optional).
- Rails project generation.
- Rails DB configuration.
- Rails initial git commit and push (optional).
- Nginx configuration.


Usage
-----

Clone the project somewhere in your machine.
bash centos_rails_installer.sh

Options
-------
Usage: centos_rails_installer.sh [-c|--config-only] [-y|--assume-yes] [-u|--system-update <y|n>] [-d|--delete-install-folder <y|n>] [-g|--install-git <y|n>] [-db <mariadb|postgresql>]
  -c --config-only: skips installation and goes straight to rails configuration.
  -y --assume-yes: assume yes to all options exept the ones specified
  -n --assume-no: assume no to all options exept the ones specified
  -u --system-update: performs system update at the beginning (default yes)
  -d --delete-install-folder: remove installation folder at the end (default yes)
  -b: install db (default yes)
  --db-type=<mariadb|postgresql>: choose db type, assumes db install: yes. By -y default is MariaDB.
  -g --install-git: install git (default yes)
