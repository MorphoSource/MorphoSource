module Morphosource
  module Collections
    class TeamsController < Morphosource::CollectionsController
      include Morphosource::Collections::LinkedTeamsControllerBehavior

      skip_load_and_authorize_resource only: [:show, :about, :facet,
        :media_projects, :media_organization_transfer_status,
        :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet
      ], instance_name: :collection

      before_action :authenticate_api_key_optional, only: :media_projects
      before_action :load_organization, only: [:show, :facet, :about,
        :media_projects, :media_organization_transfer_status,
        :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]
      before_action :create_intersections_facet, only: [:show, :facet,
        :media_projects, :media_organization_transfer_status,
        :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]
      before_action :create_access_facet, only: [:show, :facet,
        :media_projects, :media_organization_transfer_status,
        :media_export_with_intersections_facet, :media_download_counts_with_intersections_facet]

      self.presenter_class = Morphosource::Collections::TeamPresenter

      # intersections facet added by before_action :create_intersections_facet

      # Exports CSV of projects containing org media not owned by linked team
      def media_projects
        deny_access_unauthorized and return unless current_user.present?
        deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

        query_organization_media_collections

        @document_type = 'collection'
        @document_list = @collections_document_list.map { |d| d.to_semantic_values }
        @document_list.map! do |coll|
          collection = Collection.find(coll[:id]&.first)
          addl_fields = {
            url: [collection_url(coll)],
            managers: [collection.managers.map(&:name)],
            manager_emails: [collection.managers.map(&:email)],
            media_number: [media_number_in_collection(coll)]
          }

          if request.format == 'csv'
            base_fields = coll
          else
            base_fields = { id: coll[:id], title: coll[:title], collection: coll}
          end
          # change display of collection visibility
          if base_fields[:visibility] == ['restricted']
            base_fields[:visibility] = ['private']
          end
          base_fields.merge(addl_fields)
        end
        @render_only_document_list = true

        export_render('Projects%20With%20Media%20Not%20Managed%20By%20Team')
      end

      # Exports CSV of media metadata (with facets) including org transfer status
      def media_organization_transfer_status
        deny_access_unauthorized and return unless current_user.present?
        deny_access_forbidden    and return unless current_user.can?(:edit, @collection)

        if request.format == 'csv'
          repository.blacklight_config.max_per_page = 9999999
        end
        (@response, @document_list) = query_solr_all_results
        @document_list.map! do |d|
          # Derive organization transfer status
          status = ''
          if (req = ProxyDepositRequest.find_by(work_id: d.id, organization_transfer: true)).present?
            status = req.status
          elsif d['organization_transfer_on_publish_bsi']
            status = 'transfer_on_publication'
          elsif d['pending_org_transfer_bsi']
            status = 'transfer_pending'
          end

          d.to_semantic_values.merge('organization_transfer_status' => status)
        end

        export_render("Media Organization Transfer Status Query")
      end

      def collection_type
        Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Teams::SETTINGS)
      end

      private

        # link for facet filters
        def search_action_url(*args)
          args&.first&.delete("collection_id")
          main_app.team_path(@curation_concern, *args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          # args id is the solr facet
          # params id is the collection id
          request.params.delete("id")
          args.merge!(request.params)
          main_app.team_media_facet_path(@collection.id, args)
        end

        # get project or team URL for collection
        def collection_url(coll_hash)
          coll_hash[:project_or_team] == ['Project'] ?
            main_app.project_url(coll_hash[:id]) :
            main_app.team_url(coll_hash[:id])
        end

        # get number of media in collection hash
        def media_number_in_collection(coll_hash)
          Morphosource::SolrService.new.get_count("has_model_ssim:Media AND member_of_collection_ids_ssim:#{coll_hash[:id].first} AND media_organization_id_ssim:#{@organization.id}")
        end

    end
  end
end
