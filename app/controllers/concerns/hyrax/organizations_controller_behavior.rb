# Cloned from CollectionsControllerBehavior to set TeamPresenter
module Hyrax
  module OrganizationsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
    include MorphosourceHelper

    included do
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      self.presenter_class = Hyrax::OrganizationPresenter
      #self.search_builder_class = Morphosource::WorkSearchBuilder
      self.single_item_search_builder_class = Morphosource::OrganizationsSearchBuilder
      self.membership_service_class = Morphosource::Organizations::OrganizationMemberService #.new(scope: self, params: params_for_query)
      self.information_service_class = Morphosource::Organizations::OrganizationInformationService
    end

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @curation_concern.team_id.present?
        # If organization is linked to a team, this route should redirect to the org-linked team’s show page instead (MR-803)
        Rails.logger.info("MR-803: organization #{params[:id]} has team: #{@curation_concern.team_id.inspect}")
        redirect_to "/teams/#{@curation_concern.team_id.first}"
      else
        presenter
        query_organization_information
        query_organization_members
      end
    end

    def member_service
      @member_service ||= Morphosource::Organizations::OrganizationMemberService.new(scope: self, organization: @curation_concern, params: params_for_query)
    end

    def presenter
      @presenter ||= self.presenter_class.new(search_result_document(id: params[:id]), current_ability, request)
    end

    private

      # Instantiates the search builder that builds a query for a single item
      # this is useful in the show view.
      def single_item_search_builder
        single_item_search_builder_class.new(self).with(params.except(:q, :page))
      end

      # Include 'catalog' and 'hyrax/base' in the search path for views, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      def _prefixes
        @_prefixes ||= super + ['catalog', 'hyrax/base']
      end

      def query_organization_information
        @organization_information = organization_information_service.organization_information
        @organization_media_groups = @organization_information['media_groups'] ||= {}
        @organization_bso_groups = @organization_information['bso_groups'] ||= {}
        @organization_cho_groups = @organization_information['cho_groups'] ||= {}
        @organization_object_ids = @organization_information['organization_object_ids'] ||= []
      end

      def organization_information_service
        @organization_information_service ||= information_service_class.new(self, @curation_concern)
      end

      def query_organization_members
        member_works
        prepare_docs_and_filters_for_media
        prepare_docs_and_filters_for_po('bso')
        prepare_docs_and_filters_for_po('cho')
      end

      def member_works
        @response = member_service.member_media(media_filter_params)
        @media_member_docs = @response.present? ? @response.documents : []
        @media_member_count = @response.total
        @paged_media_member_docs = paginated_media_item_list

        @bso_response = member_service.member_bso(@organization_object_ids, bso_filter_params)
        @bso_member_docs = @bso_response.present? ? @bso_response.documents : []
        @bso_member_count = @bso_response.total
        @paged_bso_member_docs = paginated_bso_item_list

        @cho_response = member_service.member_cho(@organization_object_ids)
        @cho_member_docs = @cho_response.present? ? @cho_response.documents : []
        @cho_member_count = @cho_response.total
        @paged_cho_member_docs = paginated_cho_item_list
      end


      # media pagination methods
      def paginated_media_item_list
        # Uses kaminari to paginate an array to avoid need for solr documents for items here
        Kaminari.paginate_array(@media_member_docs, total_count: @media_member_count).page(media_current_page).per(rows_from_params)
      end

      def media_total_items
        @media_member_count
      end

      def media_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > media_total_pages ? media_total_pages : page
      end

      # @return [Integer] total number of pages of viewable items
      def media_total_pages
        (media_total_items.to_f / rows_from_params.to_f).ceil
      end

      def rows_from_params
        request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
      end

      # bso pagination methods
      def paginated_bso_item_list
        Kaminari.paginate_array(@bso_member_docs, total_count: @bso_member_count).page(bso_current_page).per(bso_rows_from_params)
      end

      def bso_total_items
        @bso_member_count
      end

      def bso_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > bso_total_pages ? bso_total_pages : page
      end

      def bso_total_pages
        (bso_total_items.to_f / bso_rows_from_params.to_f).ceil
      end

      def bso_rows_from_params
        request.params[:brows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:brows].to_i
      end

      # cho pagination methods
      def paginated_cho_item_list
        Kaminari.paginate_array(@cho_member_docs, total_count: @cho_member_count).page(cho_current_page).per(cho_rows_from_params)
      end

      def cho_total_items
        @cho_member_count
      end

      def cho_current_page
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        page > cho_total_pages ? cho_total_pages : page
      end

      def cho_total_pages
        (cho_total_items.to_f / cho_rows_from_params.to_f).ceil
      end

      def cho_rows_from_params
        request.params[:crows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:crows].to_i
      end

      # You can override this method if you need to provide additional inputs to the search
      # builder. For example:
      #   search_field: 'all_fields'
      # @return <Hash> the inputs required for the collection member query service
      def params_for_query
        #params.merge(q: params[:cq])

        # setting higher collection limit for paginating the array
        request_params.merge(q: params[:cq])
      end
  end
end
