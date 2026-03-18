# frozen_string_literal: true
module Morphosource
  module Transactions
    module Steps
      ##
      # Ensures organization edit groups are synced with organization_id on a change set.
      class UpdateOrganizationAccess
        include Dry::Monads[:result]

        ##
        # @param [Hyrax::ChangeSet] change_set
        #
        # @return [Dry::Monads::Result]
        def call(change_set)
          resource = change_set.model

          new_org_id = Array(change_set.organization_id).compact.first
          previous_org_id = Array(resource.organization_id).compact.first

          edit_groups = Array(resource.edit_groups)

          if previous_org_id.present? && previous_org_id != new_org_id
            edit_groups -= ["#{previous_org_id}_managers", "#{previous_org_id}_editors"]
          end

          if new_org_id.present?
            org_groups = ["#{new_org_id}_managers", "#{new_org_id}_editors"]
            edit_groups |= org_groups
          end

          resource.edit_groups = edit_groups
          Success(change_set)
        rescue StandardError => e
          Failure([:update_organization_access_failed, change_set, e.message])
        end
      end
    end
  end
end
