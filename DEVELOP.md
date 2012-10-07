# Development # 


## Engines ##

Leap Web consists of different Engines. They live in their own subdirectory and are included through bundler via their path. This way changes to the engines immediately affect the server as if they were in the main '''app''' directory.

Currently Leap Web consists of 4 Engines:

* [core](https://github.com/leapcode/leap_web/blob/master/core) - ships some dependencies that are used accross all engines. This might be removed at some point.
* [users](https://github.com/leapcode/leap_web/blob/master/users) - user registration and authorization
* [certs](https://github.com/leapcode/leap_web/blob/master/certs) - Cert distribution for the EIP client
* [help](https://github.com/leapcode/leap_web/blob/master/help)- Help ticket management

## Creating a new engine ##

### Rails plugin new ###

Create the basic tree structure for an engine using
<code>
rails plugin new ENGINE_NAME -O --full
</code>

'''-O''' will skip active record and not add a dev dependency on sqlite.
'''-full''' will create a directory structure with config/routes and app and a basic engine file.

See http://guides.rubyonrails.org/engines.html for more general info about engines.

### Require Leap Web Core ###

You need to add leap_web_core to your .gemspec:
<code>
  Gem::Specification.new do |s|
    ...
    s.add_dependency "rails" ...
    s.add_dependency "leap_web_core", "~> 0.0.1"
  end
</code>

You also need to require it before you define your engine in lib/my_engine/engine.rb:
<code>
require "leap_web_core"

module MyEngine
  class Engine < ::Rails::Engine
    ...
  end
end
</code>

### Require UI Gems ###

Leap Web Core provides a basic set of UI gems that should be used accross the engines. These include haml, sass, coffeescript, uglifier, bootstrap-sass, jquery and simple_form.

Do you want to add views, javascript and the like to your engine? Then you should use the common gems. In order to do so you need to add them to your gemspec:

<code>
  require "my_engine/version"
  require "leap_web_core/dependencies"
 
  ...

  Gem::Specification.new do |s|
    ...
    s.add_dependency "rails" ...
    s.add_dependency "leap_web_core", "~> 0.0.1"

    LeapWebCore::Dependencies.add_ui_gems_to_spec(s)
  end
</code>

You also need to require them before you define your engine in lib/my_engine/engine.rb:
<code>
require "leap_web_core"
LeapWebCore::Dependencies.require_ui_gems

module MyEngine
  class Engine < ::Rails::Engine
    ...
  end
end
</code>


## Creating Models ##

You can use the normal rails generators to create models. Since you required the leap_web_core gem you will be using CouchRest::Model. So your models inherit from CouchRest::Model::Base.
http://www.couchrest.info/model/definition.html has some good first steps for setting up the model.
CouchRest Model behaved strangely when using a model without a design block. So make sure to define an initial view: http://www.couchrest.info/model/view_objects.html .

From that point on you should be able to use the standart persistance and querying methods such as create, find, destroy and so on.


