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
            managers: [collection.managers.map(&:name_or_email)],
            manager_emails: [collection.managers.map(&:email)],
            media_number: [media_number_in_collection(coll)]
          }

          if request.format == 'csv'
            base_fields = coll
          else
            base_fields = { id: coll[:id], title: coll[:title], collection: coll}
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
          end

          d.to_semantic_values.merge('organization_transfer_status' => status)
        end

        export_render("Media Organization Transfer Status Query")
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
