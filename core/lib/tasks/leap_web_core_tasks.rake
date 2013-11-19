namespace :couchrest do

  desc "Dump all the design docs found in each model"
  task :dump => :environment do
    CouchRest::Model::Utils::Migrate.load_all_models
    CouchRest::Model::Utils::Migrate.dump_all_models
  end
end

