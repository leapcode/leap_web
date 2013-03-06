# Deployment #

These instructions are targeting a Debian GNU/Linux system. You might need to change the commands to match your own needs.

## Server Preperation ##

### Dependencies ##

The following packages need to be installed:

* git
* ruby1.9
* rubygems1.9
* couchdb (if you want to use a local couch)

### Setup Capistrano ###

We use puppet to deploy. But we also ship an example deploy.rb in config/deploy.rb.example. Edit it to match your needs if you want to use capistrano.

run `cap deploy:setup` to create the directory structure.

run `cap deploy` to deploy to the server.

## Customized Files ##

Please make sure your deploy includes the following files:

* public/config/provider.json
* config/couchdb.yml

## Couch Security ##

We recommend against using an admin user for running the webapp. To avoid this couch design documents need to be created ahead of time and the auto update mechanism needs to be disabled.
Take a look at test/setup_couch.sh for an example of securing the couch. After securing the couch migrations need to be run with admin permissions. The before_script block in .travis.yml illustrates how to do this:

```
mv test/config/couchdb.yml.admin config/couchdb.yml  # use admin privileges
bundle exec rake couchrest:migrate_with_proxies      # run the migrations
bundle exec rake couchrest:migrate_with_proxies      # looks like this needs to run twice
mv test/config/couchdb.yml.user config/couchdb.yml   # drop admin privileges
```

