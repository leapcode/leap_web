# Installation #

## Requirements ##

The webapp only depends on very basic ruby packages and installs the other requirements as gems through bundler.

### Packages ###

For now we are using ruby 1.8.7. The following packages need to be installed:

* git
* ruby1.8
* rubygems1.8
* couchdb

### Gems ###

We install most gems we depend upon through [bundler](http://gembundler.com). However the bundler gem needs to be installed and the `bundle` command needs to be available to the user used for deploy.

### Bundler ###

Run `bundle install` to install all the required gems.

## Setup ##

### Cert Distribution ###

The Webapp can hand out certs for the EIP client. These certs are either picked from a pool in CouchDB or from a file. For now you can either run [Leap CA](http://github.com/leapcode/leap_ca) to fill the pool or you can put your certs file in config/cert.

We also ship provider information through the webapp. For now please add your eip-service.json to the public/config directory.

## Running ##

Run `rails server` or whatever rack server you prefer.

