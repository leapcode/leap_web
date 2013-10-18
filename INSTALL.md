# Installation #

Please see TROUBLESHOOT.md if you run into any issues during install.

## TL;DR ##

Install git, ruby 1.9, rubygems and couchdb on your system. Then run

```
gem install bundler
git clone https://leap.se/git/leap_web
cd leap_web
git submodule init
git submodule update
bundle install --binstubs
bin/rails server
```

You will find Leap Web running on `localhost:3000`. Check out the Cert Distribution section below for setting up the cert and server config.

## Requirements ##

The webapp only depends on very basic ruby packages and installs the other requirements as gems through bundler.

### Packages ###

The following packages need to be installed:

* git
* ruby1.9.3
* rubygems
* couchdb

### Code ###

Simply clone the git repository:

```
  git clone https://leap.se/git/leap_web
  cd leap_web
```

### Gems ###

We install most gems we depend upon through [bundler](http://gembundler.com). First install bundler

```
  gem install bundler
```

Then install all the required gems:
```
  bundle install --binstubs
```

## Setup ##

### SRP submodule ###

We currently use a git submodule to include srp-js. This will soon be replaced by a ruby gem. but for now you need to run

```
  git submodule init
  git submodule update
```

### Provider Information ###

The leap client fetches provider information via json files from the server.
If you want to use that functionality please add your provider files the public/config directory.

## Running ##

```
bin/rails server
```

You'll find Leap Web running on `localhost:3000`
