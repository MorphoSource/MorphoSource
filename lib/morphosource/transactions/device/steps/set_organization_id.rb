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

            obj.organization_id = save_organization_id(attributes)
byebug
            Success(obj)
          end

          private

            # TODO: This code should be removed when organization collections
            # have been implemented on production and devices no longer are
            # associated with organization works through a parent/child relationship.

            # Coming from the device new/edit form, use work_parents_attributes to
            # populate the device organization_id.
            # If the organization is a work, proceed with adding it as a parent of the device.
            # If the organization is a collection, remove it from work_parents_attributes.
            def save_organization_id(attributes)
byebug
              attributes['organization_id'] = [] if attributes['organization_id'].blank?
              organizations = attributes['work_parents_attributes']
byebug
              organizations&.each do |k, v|
                id = v['id']
                if v['_destroy'] == "false"
                  attributes['organization_id'] << id
                else
                  attributes['organization_id'].delete(id)
                end
                if OrganizationCollection.exists?(id)
                  attributes['work_parents_attributes'].delete(k)
                end
              end
              attributes['organization_id']
            end

        end
      end
    end
  end
end
