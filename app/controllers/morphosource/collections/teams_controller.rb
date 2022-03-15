module Morphosource
  module Collections
    class TeamsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet, :media_projects], instance_name: :collection

      before_action :load_organization, only: [:show, :facet, :about, :media_projects]

      before_action :create_intersections_facet, only: [:show, :facet, :media_projects]

      self.presenter_class = Morphosource::Collections::TeamPresenter

      copy_blacklight_config_from(::MediaCatalogController)

      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status", limit: 10
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type", limit: 10
          config.add_facet_field "media_organization_ssim", label: "Organization", limit: 10
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
          # intersections facet added by before_action :create_intersections_facet
        end
      end
      configure_facets

      # Outputs CSV of projects containing org media not owned by linked team
      def media_projects
        query_organization_media_collections

        respond_to do |format|
          format.html { redirect_to main_app.team_media_path(@collection.id) }
          format.csv  { 
            @new_document_list = @collections_document_list.map { |d| d.to_semantic_values } 
            @new_document_list = @new_document_list.map do |coll|
              collection = Collection.find(coll[:id]&.first)
              coll.merge({
                url: [collection_url(coll)],
                managers: [collection.managers.map(&:name_or_email)],
                manager_emails: [collection.managers.map(&:email)],
                media_number: [media_number_in_collection(coll)]
              })
            end
            csv_response_headers('Projects%20With%20Media%20Not%20Managed%20By%20Team')
          }
        end
      end

      private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.team_media_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          args.merge!(request.params)
          main_app.team_media_facet_path(@collection.id, args)
        end

        # get project or team URL for collection
        def collection_url(coll_hash)
          coll_hash[:project_or_team] == ['Project'] ? 
            main_app.project_media_url(coll_hash[:id]) : 
            main_app.team_media_url(coll_hash[:id])
        end

        # get number of media in collection hash, based on facets
        def media_number_in_collection(coll_hash)
          facet_type = coll_hash[:project_or_team] == ['Project'] ? 
            'member_of_project_ids_ssim' : 
            'member_of_team_ids_ssim'
          facet_counts = @response['facet_counts']['facet_fields'][facet_type].each_slice(2).to_a.to_h
          facet_counts[coll_hash[:id]&.first] || 0
        end

    end
  end
end
