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
            return Failure[:no_organization_id, obj] unless obj.respond_to?(:organization_id=)
            # if attributes is nil, there is no organization_id to set, so we can just return success with the object as is
            return Success(obj) if attributes.nil?
            
            organization_ids = save_organization_id(attributes)
            return Failure["Cannot associate device with more than one organization", obj] if organization_ids.size > 1

            obj.organization_id = organization_ids
            Success(obj)
          end

          private

            def save_organization_id(attributes)
              organization_ids = Array(attributes['organization_id']).compact
              organization_ids = organization_ids.map(&:presence).compact
              organization_ids = [] if organization_ids.blank?
              organization_ids
            end

        end
      end
    end
  end
end
