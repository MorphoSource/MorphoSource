module Hyrax
  class BrowseTeamsController < My::TeamsController
    include Morphosource::CollectionHelper
    include My::MyTeamsControllerBehavior

    with_themed_layout 'morphosource_1_column'

    before_action :authenticate_user!, except: [:index]      

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

      if page_is_team?
        query_collection_information
      end
      #@response = teams_service.all_collections_by_type(@collection_list_type_id, collection_filter_params)
      @response = teams_service.all_collections_by_type(@collection_list_type_id, browse_collection_params)
      @document_list = @response.documents
      @document_count = @document_list.length
      @paginated_document_list = paginated_item_list

      if page_is_team?
        @org_teams_count = @collection_information['counts_for_team_type']['org_teams'].to_int
        @user_teams_count = @document_count - @org_teams_count
      end

      respond_to do |format|
        format.html { render 'hyrax/browse/teams/index'}
        format.rss  { render layout: false }
        format.atom { render layout: false }
      end

    end

    # overriding the default rows per page in controllers/hyrax/my/teams_controller.rb
    def rows_from_params
      request.params[:rows].nil? ? Hyrax.config.browse_page_item_rows : request.params[:rows].to_i
    end

    def query_collection_information
      @collection_information = browse_teams_information_service.collection_information_for_browse
    end

    def browse_collection_params
      return [browse_teams_information_service.browse_collection_params]
    end

    private

      def search_action_url(collection_list_type, *args)
        if collection_list_type == 'project'
          Rails.application.routes.url_helpers.browse_projects_path(*args)
        elsif collection_list_type == 'team'
          Rails.application.routes.url_helpers.browse_teams_path(*args)
        else
          hyrax.my_collections_url(*args)
        end
      end

      def collection_type_list_presenter
        @collection_type_list_presenter ||= Hyrax::SelectTeamCollectionTypeListPresenter.new(current_user)
      end

  end

end
