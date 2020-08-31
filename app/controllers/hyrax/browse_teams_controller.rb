module Hyrax
  class BrowseTeamsController < My::TeamsController
    include Morphosource::CollectionHelper
    include My::TeamsControllerBehavior

    with_themed_layout 'morphosource_1_column'

    def index
      collection_type_list_presenter
      #super
      @user = current_user 

      if page_is_project?
        @collection_list_type = "project"
        @collection_list_type_id = 2
      elsif page_is_team?
        @collection_list_type = "team"
        @collection_list_type_id = 1
      else
        @collection_list_type = "collection"
      end

      query_collection_information

      @response = teams_service.all_collections_by_type(@collection_list_type_id, collection_filter_params)
      @document_list = @response.documents
      @paginated_document_list = paginated_item_list

      respond_to do |format|
        format.html { render 'hyrax/browse/teams/index'}
        format.rss  { render layout: false }
        format.atom { render layout: false }
      end

    end

    def query_collection_information
      @collection_information = teams_information_service.collection_information
      @collection_counts = @collection_information['counts'] ||= {}
      @collection_groups = @collection_information['collection_groups'] ||= {}
    end

    def collection_filter_params
      returned_solrize_filter_params = teams_information_service.solrize_filter_params(filter_params('k_', params))
      unless params['k_membership'].present?
        # if no membership criteria, get collections with any membership value
        returned_solrize_filter_params << teams_information_service.default_membership_params          
      end
      returned_solrize_filter_params
    end

    def filter_params(prefix, params)
      return_params = {}
      temp_params = params.select{ |k,v| k.match(/^#{prefix}/) }.select{ |k,v| v.present? }
      temp_params.each do |k,v|
        return_params[k] = v
      end
      return_params
    end


    private

      def search_action_url(collection_list_type, *args)
        if collection_list_type == 'project'
          Rails.application.routes.url_helpers.my_projects_path(*args)
        elsif collection_list_type == 'team'
          Rails.application.routes.url_helpers.my_teams_path(*args)
        else
          hyrax.my_collections_url(*args)
        end
      end

      def collection_type_list_presenter
        @collection_type_list_presenter ||= Hyrax::SelectTeamCollectionTypeListPresenter.new(current_user)
      end

  end

end
