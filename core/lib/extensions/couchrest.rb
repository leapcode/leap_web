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

    module PropertyProtection

      def remove_protected_attributes(attributes)
        debugger
        sanitize_for_mass_assignment(attributes)
      end

    end

    class Base
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::ForbiddenAttributesProtection
    end

    module Embeddable
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::ForbiddenAttributesProtection
    end
  end

  class ModelRailtie
    config.action_dispatch.rescue_responses.merge!(
      'CouchRest::Model::DocumentNotFound' => :not_found,
      'RestClient::ResourceNotFound' => :not_found
    )
  end
end
