class UpdateWorkCollectionsPermissionsJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.reindex_queue_name

  def perform(object=nil)
    if object.present?
      object.member_of_collections.each do |c|
        Hyrax::PermissionTemplateApplicator.apply(c.permission_template).to(model: object)
      end
      object.save!
    end
  end
end