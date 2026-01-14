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

            # TODO: Currently all devices should be associated with organization using the organization_id (and not through a parent/child relationship).  For now, the device form is still using the parent work relations widget for add and remove organization.  Eventually we can remove the widget and this code.
            # 
            # Coming from the device new/edit form, use work_parents_attributes to
            # populate the device organization_id.
            # If the organization is a work, proceed with adding it as a parent of the device.
            # If the organization is a collection, remove it from work_parents_attributes.
            def save_organization_id(attributes)
              organization_ids = attributes['organization_id']
              organization_ids = [] if organization_ids.blank?
              organizations = attributes['work_parents_attributes']
              organizations&.each do |k, v|
                id = v['id']
                if v['_destroy'] == "false"
                  organization_ids << id
                else
                  organization_ids.delete(id)
                end
                if OrganizationCollection.exists?(id)
                  attributes['work_parents_attributes'].delete(k)
                end
              end
              organization_ids
            end

        end
      end
    end
  end
end
