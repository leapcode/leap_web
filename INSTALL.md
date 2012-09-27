Installation
-------------


### Requirements ###

This file documents installing the webapp demo on a debian system. For other systems you might have to use other commands / packages.

The webapp only depends on very basic ruby packages and installs the other requirements as gems for now. We use git for version controll and capistrano to deploy.

#### Packages ####

The following packages need to be installed:

* git
* ruby1.8
* rubygems1.8
* couchdb

#### Gems ####

We install most gems we depend upon through bundler. However the bundler gem needs to be installed and the '''bundle''' command needs to be available to the user used for deploy.

### Setup Capistrano ###

run capify in the source tree and edit config/deploy.rb to match your needs. We ship an example in config/deploy.rb.example.

run '''cap deploy:setup''' to create the directory structure.

run '''cap deploy''' to deploy to the server.

