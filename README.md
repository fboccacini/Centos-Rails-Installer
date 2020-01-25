Centos Rails Installer
======================

Work in progress
----------------

Rails interactive installer for CentOS Linux, with Passenger and Nginx.

It drives you from a fresh installed CentOS machine to a fully configured Rails installation. Well, it works on existent machines too, but testing is work in progress.. :)

Precisely it does the following:

- Adds a user for the project. It will install all the gems in its own home directory and it will run Nginx. If the specified user exists already it will be used for this purpose. If the script detects a VirtualBox VM environment, the user will also be added the the vboxsf group, so that it can access shared folders.
- System update (optional)
- EPEL enable
- Dependencies installation
- Git installation (optional)
- Local DB installation (optional). You can choose between MariaDB and Postgresql.
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

Run **bash centos_rails_installer.sh**

with no options for the interactive mode, where it will ask on every option. If you specify options without -y or -n it will assume yes for those and ask for the others.

If it's run with -y it will not ask anything assuming you'll answer always yes (at least until it reaches MariaDB or Nginx scripts). You can override the options you don't want by specifying them (see below)

If it's run with -n it will do the opposite, assuming you say no to everything. Same again you can override the options you want by specifying them (see below).

When run with -c or --config-only it will skip installation altogether and go straight to Rails project creation and configuration (use with caution).


Options
-------

  - -c : skips installation and goes straight to rails configuration.
  - -y : assume yes to all options except the ones specified
  - -n : assume no to all options except the ones specified
  - -u : performs system update at the beginning (default yes)
  - -d : remove installation folder at the end (default yes)
  - -b : install db (default yes)
  - -t mariadb|postgresql : choose db type, assumes db install: yes. By -y default is MariaDB.
  - -g : install git (default yes)

Examples
--------

bash centos_rails_installer -y -t postgres -g -> assume yes: update the system, remove intallation folder, install postgres db, do not install git

bash centos_rails_installer -n -b -g -> assume no: do not update the system, do not remove installation folder, install db (will ask which), install git
