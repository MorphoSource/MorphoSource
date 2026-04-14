# frozen_string_literal: true

# migrates models from AF to valkyrie
class MigrateResourcesJob < ApplicationJob
  attr_writer :errors

  queue_as Hyrax.config.update_medium_queue_name

  # input [Array>>String] Array of ActiveFedora model names to migrate to valkyrie objects
  # defaults to AdminSet & Collection models if empty
  def perform(ids: [], models: ['AdminSet', 'Collection'], skip_index_related_works: true)
    if ids.blank?
      models.each do |model|
        model.constantize.find_each do |item|
          migrate(item.id, skip_index_related_works)
        end
      end
    else
      ids.each do |id|
        migrate(id, skip_index_related_works)
      end
    end
    raise errors.inspect if errors.present?
  end

  def errors
    @errors ||= []
  end

  def migrate(id, skip_index_related_works)
    resource = Hyrax.query_service.find_by(id: id)
    return unless resource.wings? # this resource has already been converted
    if skip_index_related_works && resource.respond_to?(:skip_index_related_works)
      resource.skip_index_related_works = true
    end

    # Devices without a creator would fail form validation during migration.
    # Set a default so the record can be migrated; it can be corrected afterwards.
    resource.creator = ["unknown"] if resource.is_a?(DeviceResource) && resource.creator.blank?

    result = MigrateResourceService.new(resource: resource).call
    errors << result unless result.success?
    result
  end
end
