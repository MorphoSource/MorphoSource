module Morphosource
  module My
    class MediaController < WorksController
      include MediaControllerBehavior

      def self.configure_facets
        configure_blacklight do |config|
          config.add_facet_field "publication_status_ssi"
          config.add_facet_field "human_readable_media_type_tesim"
          config.add_facet_field "media_organization_ssim"
          config.add_facet_field "member_of_project_ids_ssim"
          config.add_facet_field "member_of_team_ids_ssim"
        end
      end
      configure_facets

      def index
        byebug
        prepare_page_variables
        super
      end

      # override works/index#index_response if adding media to a collection
      def index_response
        if adding_to_collection?
          respond_to do |format|
            format.html {
              render 'morphosource/my/media/index_add_to_collection'
            }
            format.rss  { render layout: false }
            format.atom { render layout: false }
          end
        else
          super
        end
      end

      def prepare_page_variables
        if adding_to_collection?
          add_to_collection_title
          media_works_page_title
        end
        add_to_collection_button_label
        batch_actions_partial
      end

      def query_solr
        search_results(params)
      end

      private

      def save_tab
        @tab = :media
      end

    end
  end
end
