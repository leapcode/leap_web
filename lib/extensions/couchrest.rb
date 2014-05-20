module CouchRest
  module Model
    class Base
      extend ActiveModel::Naming
    end
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

    module Connection

      module ClassMethods

        def use_database(db)
          @database = prepare_database(db)
        rescue RestClient::Exception,
          Errno::EHOSTUNREACH,
          Errno::ECONNREFUSED => e
          message = "Could not connect to couch database #{db} due to #{e.to_s}"
          Rails.logger.warn message
          raise e.class.new(message) if APP_CONFIG[:reraise_errors]
        end
      end

    end

    module Utils
      module Migrate
        def self.load_all_models_with_engines
          self.load_all_models_without_engines
          return unless defined?(Rails)
          Dir[Rails.root + 'engines/*/app/models/**/*.rb'].each do |path|
            require path
          end
        end

        class << self
          alias_method_chain :load_all_models, :engines
        end

        def dump_all_models
          prepare_directory
          find_models.each do |model|
            model.design_docs.each do |design|
              dump_design(model, design)
            end
          end
        end

        protected

        def dump_design(model, design)
          dir = prepare_directory model.name.tableize
          filename = design.id.sub('_design/','') + '.json'
          puts dir + filename
          design.checksum
          File.open(dir + filename, "w") do |file|
            file.write(JSON.pretty_generate(design.to_hash))
          end
        end

        def prepare_directory(dir = '')
          dir = Rails.root + 'tmp' + 'designs' + dir
          Dir.mkdir(dir) unless Dir.exists?(dir)
          return dir
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
