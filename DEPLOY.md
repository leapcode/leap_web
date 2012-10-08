# Deployment #

These instructions are targeting a Debian GNU/Linux system. You might need to change the commands to match your own needs.

## Server Preperation ##

### Dependencies ##

The following packages need to be installed:

* git
* ruby1.8
* rubygems1.8
* couchdb (if you want to use a local couch)

### Setup Capistrano ###

We use capistrano to deploy.
We ship an example deploy.rb in config/deploy.rb.example. Edit it to match your needs.

run `cap deploy:setup` to create the directory structure.

run `cap deploy` to deploy to the server.

## Customized Files ##

Please make sure your deploy includes the following files:

* config/cert
* public/config/provider.json
