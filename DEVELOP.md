# Development #

## Engines ##

Leap Web consists of different Engines. They live in their own subdirectory and are included through bundler via their path. This way changes to the engines immediately affect the server as if they were in the main `app` directory.

Currently Leap Web consists of 4 Engines:

* [core](https://github.com/leapcode/leap_web/blob/master/core) - ships some dependencies that are used accross all engines. This might be removed at some point.
* [users](https://github.com/leapcode/leap_web/blob/master/users) - user registration and authorization
* [certs](https://github.com/leapcode/leap_web/blob/master/certs) - Cert distribution for the EIP client
* [help](https://github.com/leapcode/leap_web/blob/master/help) - Help ticket management

## Creating a new engine ##

### Rails plugin new ###

Create the basic tree structure for an engine using
```
rails plugin new ENGINE_NAME -O --full
```

`-O` will skip active record and not add a dev dependency on sqlite.
`-full` will create a directory structure with config/routes and app and a basic engine file.

See http://guides.rubyonrails.org/engines.html for more general info about engines.

### Require Leap Web Core and dependencies ###

Leap Web Core provides a common set of dependencies for the engines with CouchRest Model etc.
It also comes with an optional set of UI gems like haml, sass, coffeescript, uglifier, bootstrap-sass, jquery and simple_form.

In order to use the core dependencies you need to add leap_web_core to your .gemspec:
```ruby
# make sure LeapWeb::VERSION is available
require File.expand_path('../../lib/leap_web/version.rb', __FILE__)
# ...
  Gem::Specification.new do |s|
    # ...
    s.add_dependency "rails" 
    s.add_dependency "leap_web_core", LeapWeb::Version
  end
```

You also need to require it before you define your engine in lib/my_engine/engine.rb:
```ruby
require "leap_web_core"
# uncomment if you want the ui gems:
# require "leap_web_core/ui_dependencies"

module MyEngine
  class Engine < ::Rails::Engine
    # ...
  end
end
```

Some development and UI dependencies can not be loaded via leap_web_core. To make them available add the following lines to your engines Gemfile

```ruby
  eval(File.read(File.dirname(__FILE__) + '/../common_dependencies.rb'))
  # uncomment if you want the ui gems:
  # eval(File.read(File.dirname(__FILE__) + '/../ui_dependencies.rb'))
```

## Creating Models ##

You can use the normal rails generators to create models. Since you required the leap_web_core gem you will be using CouchRest::Model. So your models inherit from CouchRest::Model::Base.
http://www.couchrest.info/model/definition.html has some good first steps for setting up the model.
CouchRest Model behaved strangely when using a model without a design block. So make sure to define an initial view: http://www.couchrest.info/model/view_objects.html .

From that point on you should be able to use the standart persistance and querying methods such as create, find, destroy and so on.


