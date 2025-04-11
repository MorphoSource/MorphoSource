# Retrieves all objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MyObjectsSearchBuilder < Hyrax::WorksSearchBuilder
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

      delegate :repository, to: :scope

      self.default_processor_chain += [:apply_object_ids_filter, :filter_collection_facet_for_access]

      private

        def apply_object_ids_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << object_ids_filter
        end

        def object_ids_filter
          "(id:(#{object_ids.join(' OR ')}))"
        end

        def object_ids
          ids =  my_edit_object_ids + my_organizations_edit_object_ids
          ids.blank? ? ['none'] : ids
        end

        def my_edit_object_ids
          # ensure to get objects with edit access even if the objects have no media
          repository.blacklight_config.max_per_page = 999999
          repository.search(Morphosource::Users::EditObjectsSearchBuilder.new(@scope).rows(999999).query).response['docs'].map { |d| d["id"] }
        end

        def my_organizations_edit_object_ids
          # ensure to get objects from organizations with edit access even if the objects have no media
          edit_access_groups = current_user.manager_groups + current_user.editor_groups + current_user.depositor_groups
          return [] if edit_access_groups.empty?

          organization_ids = []
          edit_access_groups.each do |group|
            if group.match?(/^\d+_(managers|editors|depositors)$/)
              id = group.split('_').first
              if Organization.exists?(id: id) || OrganizationCollection.exists?(id: id)
                organization_ids << id
              end
            end
          end  
          return [] if organization_ids.empty?

          repository.blacklight_config.max_per_page = 999999
          repository.search(Hyrax::PhysicalObjectsSearchBuilder.new(@scope).where("organization_id_ssim": organization_ids).rows(999999).query).response['docs'].map { |d| d["id"] }
        end

        def models
          [BiologicalSpecimen, CulturalHeritageObject]
        end

    end
  end
end
