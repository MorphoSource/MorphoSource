module Hyrax
  module My
    class MediaWorksController < MyController
      include MediaWorksControllerBehavior
      with_themed_layout 'morphosource_dashboard'

      helper_method :media_works_url, :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
        :media_type_label
      
      def media_works_url(tab)
        Rails.application.routes.url_helpers.my_media_index_path + "#" + tab
      end

      def query_collection_information
        @collection_information = collection_information_service.collection_information
        @collection_counts = @collection_information['counts'] ||= {}
        @collection_media_groups = @collection_information['media_groups'] ||= {}
        @collection_bso_groups = @collection_information['bso_groups'] ||= {}
        @collection_cho_groups = @collection_information['cho_groups'] ||= {}
        @collection_object_ids = @collection_information['collection_object_ids'] ||= []
        @collection_organization_object_ids = @collection_information['organization_object_ids'] ||= []
      end

      def media_filter_params
        collection_information_service.solrize_filter_params(filter_params('m_', params))
      end

      def bso_filter_params
        collection_information_service.solrize_filter_params(filter_params('b_', params))
      end

      def cho_filter_params
        collection_information_service.solrize_filter_params(filter_params('c_', params))
      end

      def filter_params(prefix, params)
        return_params = {}
        temp_params = params.select{ |k,v| k.match(/^#{prefix}/) }.select{ |k,v| v.present? }
        temp_params.each do |k,v|
          return_params[k] = v
        end
        return_params
      end

      def hidden_params_for_filters(prefix)
        hidden_params = {}
        params = request.params
        hidden_params.merge!({'view' => params['view']}) if params['view'].present?
        hidden_params.merge!({'rows' => params['rows']}) if params['rows'].present?
        hidden_params.merge!({'brows' => params['brows']}) if params['brows'].present?
        hidden_params.merge!({'crows' => params['crows']}) if params['crows'].present?
        if params['add_works_to_collection'].present?
          hidden_params.merge!({'add_works_to_collection' => params['add_works_to_collection']}) 
          hidden_params.merge!({'add_works_to_collection_label[]' => params['add_works_to_collection_label'].first}) 
        end
        html = ''
        hidden_params.map do |k,v|
          html += '<input type="hidden" name="' + k + '" value="' + v + '" />'
        end
        html.html_safe
      end

      def hidden_params_for_pagination(prefix)
        hidden_params = {}
        params = request.params
        hidden_params.merge!({'view' => params['view']}) if params['view'].present?
        html = ''
        hidden_params.map do |k,v|
          html += '<input type="hidden" name="' + k + '" value="' + v + '" />'
        end
        params.map do |k,v|
          html += '<input type="hidden" name="' + k + '" value="' + v + '" />' if k.include? prefix
        end
        html.html_safe
      end

      def path_info(request)
        request.env['PATH_INFO']
      end

      def bso_tab_url
        url_params = request_params.
          map { |k, v| "#{k}=#{v}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
          compact.
          join('&')
        "/dashboard/my/media/specimens?#{url_params}"
      end

      def cho_tab_url
        url_params = request_params.
          map { |k, v| "#{k}=#{v}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
          compact.
          join('&')
        "/dashboard/my/media/chos?#{url_params}"
      end

      def prepare_docs_and_filters_for_media
        @po_type = "bso" # bso / cho
  #      @is_team = collection.team?
        @visibility_options = []

  #      @team_project_options = @subcollection_docs.map(&:title).flatten # [] for projects
        @bso_visibility_options = []
        @bso_source_options = []
        @cho_visibility_options = []

        @media_member_docs = @response.documents
        @media_member_count = @response.total
        @paged_media_member_docs = paginated_media_item_list
        @document_list = @paged_media_member_docs
        @media_extras = get_media_extras(@paged_media_member_docs)
      end

      def get_media_extras(docs)
        docs.map do |doc|
          this_media_extras = { 
            'id' => doc.id
          }

          # get BSO and CHO
          po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
          if po_doc.present?
            this_media_extras['po_title'] = po_doc.title&.first
            if po_doc.hydra_model == BiologicalSpecimen
              @po_type = "bso"
              taxonomy = Morphosource::TaxonomySearchService.call({ 'id' => po_doc.taxonomy_id&.first})&.first if po_doc.taxonomy_id.present?
              this_media_extras['po_taxonomy'] = taxonomy.title&.first if taxonomy.present? && taxonomy.title.present?
            elsif po_doc.hydra_model == CulturalHeritageObject
              @po_type = "cho"
            end
          end

          this_media_extras
        end
      end

      def prepare_docs_and_filters_for_po(obj_type)
        case obj_type
        when 'bso'
          @bso_visibility_options = []
          @bso_source_options = []
          @paged_bso_member_docs = paginated_bso_item_list
          @bso_total_pages = bso_total_pages
          @bso_source_options = @bso_source_options.uniq
          @bso_extras = get_po_extras(@paged_bso_member_docs)
        when 'cho'
          @cho_visibility_options = []
          @paged_cho_member_docs = paginated_cho_item_list
          @cho_total_pages = cho_total_pages
          @cho_extras = get_po_extras(@paged_cho_member_docs)
        end
      end

      def get_po_extras(docs)
        docs.map do |doc|
          {
            'id' => doc.id,
            'origin' => po_origin(doc.id),
            'media_count' => Morphosource::PhysicalObjectParentSearchService.total_media_count(doc.id)
          }
        end
      end

      def po_origin(id)
        if @collection_organization_object_ids.present? && @collection_organization_object_ids.include?(id)
          'Org.'
        else
          'Team'
        end
      end

      def visibility_label(value)
        case value
        when 'open'
          display_value = "Public"
        when 'authenticated'
          display_value = "Duke University"
        when 'restricted'
          display_value = "Private"
        else
          display_value = value
        end
        display_value
      end

      def publication_status_label(value)
        case value
        when 'open'
          display_value = "Open Download"
        when 'restricted_download'
          display_value = "Restricted Download"
        when 'preview_only'
          display_value = "No Download"
        when 'hidden'
          display_value = "Hidden"
        when 'private'
          display_value = "Private"
        when 'embargo'
          display_value = "Embargo"
        when 'lease'
          display_value = "Lease"
        else
          display_value = value
        end
        display_value
      end

      def media_type_label(value)
        case value
        when 'CTImageSeries'
          'CT Image Series'
        else
          value.underscore.titleize
        end
      end

      def origin_label(value)
        case value
        when 'team_organization'
          'Organization Linked To Team'
        when 'team_collection'
          'Direct Team Ownership'
        else
          ''
        end
      end

      def source_label(value)
        case value
        when 'idigbio'
          'iDigBio Aggregator'
        when 'user'
          'User Created'
        else
          ''
        end
      end

      def organization_from_bso(bso)
        Organization.find(bso.organization_id&.first) if bso.organization_id.present?
      end


      # Define collection specific filter facets.
      #def self.configure_facets
      #  configure_blacklight do |config|
      #    config.add_facet_field solr_name("admin_set", :facetable), limit: 5
      #    config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5
      #  end
      #end
      #configure_facets

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      # Search builder for a list of works that belong to me
      # Override of Blacklight::RequestBuilders
      def search_builder_class
        Hyrax::My::WorksSearchBuilder
      end

      def index
        @user_collections_for_view = collections_service.search_results(:view)
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        #presenter
        query_collection_information
        query_collection_members
        prepare_instance_variables_for_batch_control_display
        prepare_for_add_to_collection
        respond_to do |format|
          format.html {
            if @is_add_to_collection
              render 'index_add_to_collection'
            else
              add_breadcrumb t(:'hyrax.controls.home'), root_path
              add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
              render 'index'
            end
          }
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end
      end

      def specimens
        @user_collections_for_view = collections_service.search_results(:view)
        #presenter
        query_collection_information
        query_collection_members_for_po('bso')
        render :partial => 'tab_bso'
      end

      def chos
        @user_collections_for_view = collections_service.search_results(:view)
        #presenter
        query_collection_information
        query_collection_members_for_po('cho')
        render :partial => "tab_cho"
      end

      private

        def collections_service
          Hyrax::CollectionsService.new(self)
        end

        def search_action_url(*args)
          hyrax.my_works_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_works_facet_path(args[:id])
        end

        def managed_works_count
          @managed_works_count = Hyrax::Works::ManagedWorksService.managed_works_count(scope: self)
        end
    end
  end
end