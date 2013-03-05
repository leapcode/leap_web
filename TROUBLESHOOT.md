# Troubleshooting #

Here are some less common issues you might run into when installing Leap Web.

## Cannot find Bundler ##

### Error Messages ###

`bundle: command not found`

### Solution ###

Make sure bundler is installed. `gem list bundler` should list `bundler`.
You also need to be able to access the `bundler` executable in your PATH.

## Outdated version of rubygems ##

### Error Messages ###

`bundler requires rubygems >= 1.3.6`

### Solution ###

`gem update --system` will install the latest rubygems

## Missing development tools ##

Some required gems will compile C extensions. They need a bunch of utils for this.

### Error Messages ###

`make: Command not found`

### Solution ###

Install the required tools. For linux the `build-essential` package provides most of them. For Mac OS you probably want the XCode Commandline tools.

## Missing libraries and headers ##

Some gem dependencies might not compile because they lack the needed c libraries.

### Solution ###

Install the libraries in question including their development files.


