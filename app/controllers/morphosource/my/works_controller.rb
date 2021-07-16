module Morphosource
  module My
    class WorksController < Hyrax::My::WorksController
      include Morphosource::My::WorksControllerBehavior
      include Morphosource::Facets::AccessFilters
      include Morphosource::My::WorksHelper

      class_attribute :create_work_presenter_class, :filtered_facets

      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      with_themed_layout 'morphosource_dashboard'

      before_action :tab_variables, only: [:index]

      before_action :set_facet_limit, only: [:index]

      def index
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)
        add_breadcrumbs
        # media/object counts at top of page
        get_media_object_counts
        # managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        (@response, @document_list) = query_solr
        # get_viewable_collections_ids
        filter_facets
        prepare_instance_variables_for_batch_control_display
        respond_to do |format|
          format.html {
            render 'morphosource/my/works/index'
          }
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end
      end

      # remove collections from team and project facets that the user is not able to view
      # def filter_facets
      #   get_viewable_collections_ids
      #   return if current_user.admin?
      #   filtered_facets.each do |facet|
      #     items = @response.aggregations[facet].items
      #     unauthorized_items = unauthorized_items(items)
      #     unauthorized_items.each do |item|
      #       items.delete(item)
      #     end
      #   end
      # end

      # displays values and pagination links for a single facet field
      # overrides Blacklight 6.23.0 app/controllers/concerns/blacklight/catalog
      # def facet
      #   get_viewable_collections_ids
      #   super
      # end

      # sets the facet limit for dashboard media & objects pages
      def ms_default_facet_limit
        current_user.admin? ? 15 : 999999
      end

      # def get_viewable_collections_ids
      #   @viewable_collections_ids ||= Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability)
      # end

    end
  end
end
