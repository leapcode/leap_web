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

