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
          # @param change_set [#organization_id=] the change set to update
          # @param organization_id [String, nil] the organization ID to assign. When nil or blank,
          #   the step succeeds without modification (organization is optional).
          #
          # @return [Dry::Monads::Result]
          def call(change_set, organization_id: nil)
            return Failure[:no_organization_id, change_set] unless change_set.respond_to?(:organization_id=)

            ids = Array(organization_id).map(&:presence).compact

            if ids.empty?
              return Success(change_set)
            end

            return Failure["Cannot associate device with more than one organization", change_set] if ids.size > 1

            change_set.organization_id = ids
            Success(change_set)
          rescue StandardError => e
            Failure([:set_organization_id_failed, change_set, e.message])
          end
        end
      end
    end
  end
end
