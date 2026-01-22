module FreyjaWithWings
  class Persister < ::Freyja::Persister
    # Generic Valkyrie models that signal we are actually looking at an AF work
    AF_RESOURCES = ["Hyrax::PcdmCollection", "Hyrax::Work", "CollectionResource"]

    # Persists a resource within the database
    #
    # Modified from the upstream to use Wings for AF-only models
    #
    # @param [Valkyrie::Resource] resource
    # @return [Valkyrie::Resource] the persisted/updated resource
    # @raise [Valkyrie::Persistence::StaleObjectError] raised if the resource
    #   was modified in the database between been read into memory and persisted
    # rubocop:disable Lint/UnusedMethodArgument

    def save(resource:, external_resource: false, perform_af_validation: false)
      # If resource is a Valkyrie resource, save it using Wings
      if AF_RESOURCES.include?(resource.model_name)
        wings_persister = Wings::Valkyrie::Persister.new(adapter: Wings::Valkyrie::MetadataAdapter.new)
        wings_persister.save(resource: resource, external_resource: external_resource, perform_af_validation: perform_af_validation)
      else
        super
      end
    end

    def convert_and_migrate_resource(orm_object, was_wings)
      new_resource = resource_factory.to_resource(object: orm_object)
      # if the resource was wings and is now a Valkyrie resource, we need to migrate sipity, files, and members
      if Hyrax.config.valkyrie_transition? && was_wings && !new_resource.wings?
        MigrateFilesToValkyrieJob.perform_later(new_resource) if new_resource.is_a?(Hyrax::FileSet) && new_resource.file_ids.size == 1 && new_resource.file_ids.first.id.to_s.match('/files/')
        # migrate any members found through query service if the resource is a Hyrax work
        if new_resource.is_a?(Hyrax::Work)
          MigrateSipityEntityJob.perform_now(id: new_resource.id.to_s)
          member_ids = new_resource.member_ids.map(&:to_s)
          if member_ids.present?
            valkyrized_member_ids = Hyrax.query_service.find_many_by_ids(ids: member_ids).map(&:id).map(&:to_s)
            MigrateResourcesJob.perform_later(ids: valkyrized_member_ids) unless valkyrized_member_ids.empty?
          end
        end
      end
      new_resource
    end
  end
end