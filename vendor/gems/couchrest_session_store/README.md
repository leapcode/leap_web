# CouchRest::Session::Store #

A simple session store based on CouchRest Model.

## Setup ##

`CouchRest::Session::Store` will automatically pick up the config/couch.yml
file used by CouchRest Model.

Cleaning up sessions requires a design document in the sessions database that
enables querying by expiry. See `design/Session.json` for an example. This
design document is loaded for tests, but you will need to load it on your own
in a production environment. For example:

    curl -X PUT username:password@localhost:5984/couchrest_sessions/_design/Session --data @design/Session.json

## Options ##

* marshal_data: (_defaults true_) - if set to false session data will be stored
  directly in the couch document. Otherwise it's marshalled and base64 encoded
  to enable restoring ruby data structures.
* database: database to use combined with config prefix and suffix
* expire_after: lifetime of a session in seconds.

## Dynamic Databases ##

This gem also includes the module `CouchRest::Model::DatabaseMethod`, which
allow a Model to dynamically choose what database to use.

An example of specifying database dynamically:

    class Token < CouchRest::Model::Base
      include CouchRest::Model::DatabaseMethod

      use_database_method :database_name

      def self.database_name
        time = Time.now.utc
        "tokens_#{time.year}_#{time.month}"
      end
    end

A couple notes:

Once you include `CouchRest::Model::DatabaseMethod`, the database is no longer
automatically created. In this example, you would need to run
`Token.database.create!` or `Token.database!` in order to create the database.

The symbol passed to `database_method` must match the name of a class method,
but if there is also an instance method with the same name then this instance
method will be called when appropriate. To state the obvious, tread lightly:
there be dragons when generating database names that depend on properties of
the instance.

## Database Rotation ##

The module `CouchRest::Model::Rotation` can be included in a Model in
order to use dynamic databases to perform database rotation.

CouchDB is not good for ephemeral data because old documents are never really
deleted: when you deleted a document, it just appends a new revision. The bulk
of the old data is not stored, but it does store a record for each doc id and
revision id for the document. In the case of ephemeral data, like tokens,
sessions, or statistics, this will quickly bloat the database with a ton of
useless deleted documents. The proper solution is to rotate the databases:
create a new one regularly and delete the old one entirely. This will allow
you to recover the storage space.

A better solution might be to just use a different database for all
ephemeral data, like MariaDB or Redis. But, if you really want to use CouchDB, this
is how you can do it.

An example of specifying database rotation:

    class Token < CouchRest::Model::Base
      include CouchRest::Model::Rotation

      rotate_database 'tokens', :every => 30.days
    end

Then, in a task triggered by a cron job:

    CouchRest::Model::Base.configure do |conf|
      conf.environment = Rails.env
      conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.admin.yml')
    end
    Token.rotate_database_now(:window => 1.day)

Or perhaps:

    Rails.application.eager_load!
    CouchRest::Model::Rotation.descendants.each do |model|
      model.rotate_database_now
    end

The `:window` argument to `rotate_database_now` specifies how far in advance we
should create the new database (default 1.day). For ideal behavior, this value
should be GREATER than or equal to the frequency with which the cron job is
run. For example, if the cron job is run every hour, the argument can be
`1.hour`, `2.hours`, `1.day`, but not `20.minutes`.

The method `rotate_database_now` will do nothing if the database has already
been rotated. Otherwise, as needed, it will create the new database, create
the design documents, set up replication between the old and new databases,
and delete the old database (once it is not used anymore).

These actions will require admin access, so if your application normally runs
without admin rights you will need specify a different configuration for
CouchRest::Model before `rotate_database_now` is called.

Known issues:

* If you change the rotation period, there will be a break in the rotation
  (old documents will not get replicated to the new rotated db) and the old db
  will not get automatically deleted.

* Calling `Model.database.delete!` will not necessarily remove all the
  relevant databases because of the way prior and future databases are kept
  for the 'window' period.

## Changes ##

0.3.0

* Added support for dynamic and rotating databases.

0.2.4

* Do not crash if can't connect to CouchDB

0.2.3

* Better retry and conflict catching.d