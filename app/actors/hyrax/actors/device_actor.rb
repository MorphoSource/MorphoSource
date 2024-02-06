# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  module Actors
    class DeviceActor < Hyrax::Actors::BaseActor

      def create(env)
        save_organization_id(env)
        super
      end

      def update(env)
        save_organization_id(env)
        super
      end

      private

        # TODO: This code should be removed when organization collections
        # have been implemented on production and devices no longer are
        # associated with organization works through a parent/child relationship.

        # Coming from the device new/edit form, use work_parents_attributes to
        # populate the device organization_id.
        # If the organization is a work, proceed with adding it as a parent of the device.
        # If the organization is a collection, remove it from work_parents_attributes.
        def save_organization_id(env)
          env.attributes['organization_id'] ||= []
          organizations = env.attributes['work_parents_attributes']
          organizations&.each do |k, v|
            id = v['id']
            if v['_destroy'] == "false"
              env.attributes['organization_id'] << id
            else
              env.attributes['organization_id'].delete(id)
            end
            if OrganizationCollection.exists?(id)
              env.attributes['work_parents_attributes'].delete(k)
            end
          end
        end
    end
  end
end
