# Vagrant Sensu (Sandbox)

A ready to go Centos 6.5 Sensu client/server VM's with all dependencies.

## Pre-requisites

- Vagrant
- VirtualBox
- Ruby / Bundler

## Usage

Install the required gems:

    $ bundle install

Install the required Puppet modules:

    $ librarian-puppet install

Bring up the VM:

    $ vagrant up
