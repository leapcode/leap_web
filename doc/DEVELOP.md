# Development #

## Branches

We use the 'master' branch to hold the version currently deployed to the
production servers. Only hotfixes are applied here.

Most of development happens based upon the 'develop' branch. So unless
you are investigating a specific issue that occured in production you
probably want to base your changes on 'develop':
```
git checkout origin/develop -b my-new-feature
```
This will create a new branch called 'my-new-feature' based on the develop
branch from the origin remote.

## Setting up the local CouchDB

CouchDB operates in Admin Party by default, meaning there are no access
control checks. This is handy for local development. However, there is
the risk that running tests with Couch in Admin Party yields false
results.

We recommend keeping the default CouchDB configuration locally and testing
the more complex setup with access control in Continuous Integration.

Please see .travis.yml for the configuration of our CI runs.

In order to prepare you local couch for development run
```
bin/rake db:rotate
bin/rake db:migrate
```

### Customized database configuration (advanced)

If you want to stop Admin Party mode you need to create user accounts &
security docs. You can use the following script as a guideline:
    test/travis/setup_couch.sh

Afterwards copy & adapt the default database configuration:

```
mv config/couchdb.example.yml config/couchdb.yml
mv config/couchdb.admin.example.yml config/couchdb.admin.yml
```

## Continuous Integration ##

See https://travis-ci.org/leapcode/leap_web for CI reports on travis.
(configured in .travis.yml)

We also run builds on with gitlab runners:
https://0xacab.org/leap/leap_web/pipelines
(configured in .gitlab.yml)

## Views ##

Some tips on modifying the views:

* Many of the forms use [simple_form gem](https://github.com/plataformatec/simple_form)
* We still use client_side_validations for the validation code but since it is not maintained anymore we want to drop it asap.

## Engines ##

We use engines to separate optional functionality from the core. They live in their own subdirectory and are included through bundler via their path. This way changes to the engines immediately affect the server as if they were in the main `app` directory.

Currently Leap Web includes 2 Engines:

* [support](https://github.com/leapcode/leap_web/blob/master/engines/support) - Help ticket management
* [billing](https://github.com/leapcode/leap_web/blob/master/engines/billing) - Billing System

## Creating a new engine (advanced) ##

If you want to add functionality to the webapp but keep it easy to remove you might consider adding an engine. This only makes sense if your engine really is a plugin - so no other pieces of code depend on it.

### Rails plugin new ###

Create the basic tree structure for an engine using
```
rails plugin new ENGINE_NAME -O --full
```

`-O` will skip active record and not add a dev dependency on sqlite.
`-full` will create a directory structure with config/routes and app and a basic engine file.

See http://guides.rubyonrails.org/engines.html for more general info about engines.

You need to require engine specific gems in lib/my_engine/engine.rb:

```ruby
require "my_dependency"

module MyEngine
  class Engine < ::Rails::Engine
    # ...
  end
end
```

## Creating Models ##

You can use the normal rails generators to create models. You probably want to require couchrest_model so your models inherit from CouchRest::Model::Base.
http://www.couchrest.info/model/definition.html has some good first steps for setting up the model.
CouchRest Model behaved strangely when using a model without a design block. So make sure to define an initial view: http://www.couchrest.info/model/view_objects.html .

From that point on you should be able to use the standart persistance and querying methods such as create, find, destroy and so on.

## Writing Tests ##

### Locale

The ApplicationController defines a before filter #set_locale that will set
the default_url_options to include the appropriate default {:locale => x} param.

However, paths generated in tests don't use default_url_options. This can
create failures for certain nested routes unless you explicitly provide
:locale => nil to the path helper. This is not needed for actual path code in
the controllers or views, only when generating paths in tests.

For example:

    test "robot" do
      login_as @user
      visit robot_path(@robot, :locale => nil)
    end

## Debugging Production (advanced)

Sometimes bugs only show up when deployed to the live production server. Debugging can be tricky,
because the open source mod_passenger does not support debugger. You can't just run
`rails server` because HSTS records for your site will make most browsers require TLS.

One solution is to temporarily modify the apache config to proxypass the TLS requests to rails:

    <virtualhost *:443>
      ProxyPass / http://127.0.0.1:3000/
      ProxyPassReverse / http://127.0.0.1:3000/
      ProxyPreserveHost on
      ....
    </virtualhost>
