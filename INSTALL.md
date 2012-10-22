# Installation #

## TL;DR ##

Install git, ruby, rubygems, bundler and couchdb on your system. Then run

```
git clone git://github.com/leapcode/leap_web.git
cd leap_web
bundle install
git submodule init
git submodule update
bundle exec rails server
```

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
  git clone git://github.com/leapcode/leap_web.git
  cd leap_web
```

### Gems ###

We install most gems we depend upon through [bundler](http://gembundler.com). However the bundler gem needs to be installed and the `bundle` command needs to be available to the user used for deploy.

### Bundler ###

Install all the required gems:
```
  bundle install
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
bundle exec rails server
```

