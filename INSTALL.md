# Installation #

## Requirements ##

The webapp only depends on very basic ruby packages and installs the other requirements as gems through bundler.

### Packages ###

The following packages need to be installed:

* git
* ruby (1.8.7 and 1.9.3 work)
* rubygems
* couchdb

### Gems ###

We install most gems we depend upon through [bundler](http://gembundler.com). However the bundler gem needs to be installed and the `bundle` command needs to be available to the user used for deploy.

### Bundler ###

Run `bundle install` to install all the required gems.

## Setup ##

### SRP submodule ###

We currently use a git submodule to include srp-js. This will soon be replaced by a ruby gem. but for now you need to run

```
  git submodule init
  git submodule update
```

### Cert Distribution ###

The Webapp can hand out certs for the EIP client. These certs are either picked from a pool in CouchDB or from a file. For now you can either run [Leap CA](http://github.com/leapcode/leap_ca) to fill the pool or you can put your certs file in config/cert.

We also ship provider information through the webapp. For now please add your eip-service.json to the public/config directory.

## Running ##

Run `rails server`, `bundle exec rails server` or whatever rack server you prefer.

