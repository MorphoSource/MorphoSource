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
        if new_resource.is_a?(Hyrax::FileSet)
          if new_resource.respond_to?(:is_remote_backed?) && new_resource.is_remote_backed?
            MigrateExternalFilesToValkyrieJob.perform_later(new_resource)
          elsif new_resource.file_ids.size == 1 && new_resource.file_ids.first.id.to_s.match('/files/')
            MigrateFilesToValkyrieJob.perform_later(new_resource)
          end
        end

        # migrate any members found through query service if the resource is a Hyrax work
        if new_resource.is_a?(Hyrax::Work)
          MigrateSipityEntityJob.perform_now(id: new_resource.id.to_s)

          # Migrate child works able to be valkyrized but have not yet been migrated
          new_resource.member_ids.map(&:to_s).each do |member_id|
            child = begin
              Hyrax.query_service.find_by(id: member_id)
            rescue Valkyrie::Persistence::ObjectNotFoundError
              nil
            end

            MigrateResourcesJob.perform_later(ids: [member_id]) if (child.present? && child.wings?)
          rescue Valkyrie::Persistence::ObjectNotFoundError
            next
          end

          # If new resource has AF record that is member of AF works, update membership to refer to resource
          # Solr-based existence check (not ActiveFedora::Base.exists?, which does a full LDP fetch + RDF
          # parse) avoids crashing on Fedora objects whose stored RDF graph fails to parse.
          if (
            ActiveFedora::SolrService.count("member_ids_ssim:#{new_resource.id.to_s}") > 0 &&
            ActiveFedora::SolrService.count("id:#{new_resource.id.to_s}") > 0
          )
            af_object = ActiveFedora::Base.find(new_resource.id.to_s)
            af_object.member_of.select { |p| p.is_a?(ActiveFedora::Base) }.each do |parent|
              parent.ordered_members.delete(af_object)
              parent.members.delete(af_object)
              parent.valkyrie_member_ids = (parent.valkyrie_member_ids.to_a + [new_resource.id.to_s]).uniq
              parent.save!
            end
          end
        end
      end
      new_resource
    end

    # Deletes a resource persisted within the database
    # @param [Valkyrie::Resource] resource
    # @return [Valkyrie::Resource] the deleted resource
    def delete(resource:)
      # super is a no-op for Wings-backed resources (Freyja::Persister has no #delete, so it
      # falls through to a pure Postgres row delete); dispatch those to Wings instead, like #save does.
      resource = if resource.respond_to?(:wings?) && resource.wings?
                   Wings::Valkyrie::Persister.new(adapter: Wings::Valkyrie::MetadataAdapter.new).delete(resource: resource)
                 else
                   super
                 end

      # If deleted resource has AF record and is member of AF works, reset membership to refer to AF record
      # Solr-based existence check (not ActiveFedora::Base.exists?, which does a full LDP fetch + RDF
      # parse) avoids crashing on Fedora objects whose stored RDF graph fails to parse.
      if (
        ActiveFedora::SolrService.count("id:#{resource.id.to_s}") > 0 &&
        (parents = ActiveFedora::Base.where(valkyrie_member_ids_ssim: resource.id.to_s)).present?
      )
        af_object = ActiveFedora::Base.find(resource.id.to_s)
        parents.each do |parent|
          parent.valkyrie_member_ids = (parent.valkyrie_member_ids.to_a - [resource.id.to_s]).uniq
          parent.ordered_members << af_object unless parent.ordered_members.include?(af_object)
          parent.save!
        end
      end

      resource
    end
  end
end