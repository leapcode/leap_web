namespace :couchrest do

  desc "Dump all the design docs found in each model"
  task :dump => :environment do
    CouchRest::Model::Utils::Migrate.load_all_models
    CouchRest::Model::Utils::Migrate.dump_all_models
  end
end

namespace :cleanup do
  desc "Cleanup all expired session documents"
  task :sessions => :environment do
    # make sure this is the same as in
    #   config/initializers/session_store.rb
    store = CouchRest::Session::Store.new expire_after: 1800
    store.cleanup(store.expired)
  end

  desc "Cleanup all expired tokens"
  task :tokens => :environment do
    Token.destroy_all_expired
  end
end

namespace :db do
  desc "Rotate the databases, as needed."
  task :rotate => :environment do
    #
    # db rotation must be performed by admin, and since
    # CouchRest::Session::Document is not a CouchRest::Model, we need to
    # override the default config twice.
    #

    CouchRest::Model::Base.configure do |conf|
      conf.environment = Rails.env
      conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.admin.yml')
    end
    Token.rotate_database_now(:window => 1.day)

    CouchRest::Session::Document.configure do |conf|
      conf.environment = Rails.env
      conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.admin.yml')
    end
    CouchRest::Session::Document.rotate_database_now(:window => 1.day)
  end

  desc "Delete and recreate temporary databases."
  task :deletetmp => :environment do
    # db deletion and creation must be performed by admin
    CouchRest::Model::Base.configure do |conf|
      conf.environment = Rails.env
      conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.admin.yml')
    end
    User.tmp_database.recreate!
    User.design_doc.sync!(User.tmp_database)
  end

end
