module CouchRest
  module Model
    module Designs

      class View

        # so we can called Ticket.method.descending or Ticket.method.ascending
        def ascending
          self
        end
      end

      class DesignMapper
        def load_views(dir)
          Dir.glob("#{dir}/*.js") do |js|
            name = File.basename(js, '.js')
            file = File.open(js, 'r')
            view name.to_sym,
              :map => file.read,
              :reduce => "function(key, values, rereduce) { return sum(values); }"
          end
        end
      end
    end

    module Errors
      class ConnectionFailed < CouchRestModelError; end
    end

    module Connection

      module ClassMethods

        def use_database(db)
          @database = prepare_database(db)
        rescue RestClient::Unauthorized,
          Errno::EHOSTUNREACH,
          Errno::ECONNREFUSED => e
          raise CouchRest::Model::Errors::ConnectionFailed.new(e.to_s)
        end
      end

    end

    module Utils
      module Migrate
        def self.load_all_models_with_engines
          self.load_all_models_without_engines
          return unless defined?(Rails)
          Dir[Rails.root + 'app/models/**/*.rb'].each do |path|
            require path
          end
          Dir[Rails.root + '*/app/models/**/*.rb'].each do |path|
            require path
          end
        end

        def self.all_models_and_proxies
          callbacks = migrate_each_model(find_models)
          callbacks += migrate_each_proxying_model(find_proxying_models)
          cleanup(callbacks)
        end



        class << self
          alias_method_chain :load_all_models, :engines
        end

      end
    end
  end

  class ModelRailtie
    config.action_dispatch.rescue_responses.merge!(
      'CouchRest::Model::DocumentNotFound' => :not_found,
      'RestClient::ResourceNotFound' => :not_found
    )
  end
end
