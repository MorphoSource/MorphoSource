# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      module Steps
        ##
        # A step that sets the organization_id attribute for a `ValkyrieChangeSet` for a device work.
        class SetOrganizationID
          include Dry::Monads[:result]

          ##
          # @param [#organization_id=] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj, attributes: nil)
            Rails.logger.info("[Device::SetOrganizationID] applying organization_id to #{obj.class.name}")
            Rails.logger.debug("[Device::SetOrganizationID] incoming attributes keys: #{attributes&.keys}")
            return Failure[:no_organization_id, obj] unless obj.respond_to?(:organization_id=)

            organization_ids, source = organization_ids_from_form_or_request(obj)
            Rails.logger.info("[Device::SetOrganizationID] organization_id from #{source}: #{organization_ids.inspect}")

            return Failure["Cannot associate device with more than one organization", obj] if organization_ids.size > 1
            obj.organization_id = organization_ids
            Success(obj)
          end

          private

            def organization_ids_from_form_or_request(obj)
              organization_id_from_input = organization_ids_from_input_params(obj)
              return [organization_id_from_input, 'input_params'] if organization_id_from_input

              organization_id_from_request = organization_ids_from_request_params(obj)
              return [organization_id_from_request, 'request_params'] if organization_id_from_request

              [[], 'fallback empty']
            end

            def organization_ids_from_input_params(obj)
              return nil unless obj.respond_to?(:input_params)
              input_params = obj.input_params
              return nil unless input_params.respond_to?(:key?) && input_params.key?('organization_id')

              normalize_organization_ids(input_params['organization_id'])
            end

            def organization_ids_from_request_params(obj)
              return nil unless obj.respond_to?(:controller)
              params = obj.controller&.params
              return nil unless params.present?

              if params.key?('organization_id')
                return normalize_organization_ids(params['organization_id'])
              elsif params['device_resource']&.respond_to?(:key?) && params['device_resource'].key?('organization_id')
                return normalize_organization_ids(params['device_resource']['organization_id'])
              elsif params['device']&.respond_to?(:key?) && params['device'].key?('organization_id')
                return normalize_organization_ids(params['device']['organization_id'])
              end

              nil
            end

            def normalize_organization_ids(values)
              organization_ids = Array(values).compact
              organization_ids = organization_ids.map(&:presence).compact
              organization_ids
            end
        end
      end
    end
  end
end
