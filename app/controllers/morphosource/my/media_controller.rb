module Morphosource
  module My
    class MediaController < WorksController
      include MediaControllerBehavior

      def self.configure_facets
        configure_blacklight do |config|
          config.search_builder_class = Morphosource::Users::MyMediaSearchBuilder
          # clear catalog facet fields
          config.facet_fields = {}
          config.add_facet_field "publication_status_ssi", label: "Publication Status"
          config.add_facet_field "human_readable_media_type_ssim", label: "Media Type"
          # change to ids?
          config.add_facet_field "media_organization_ssim", label: "Organization"
          config.add_facet_field "member_of_project_ids_ssim", label: "Project", helper_method: :collection_title_by_id
          config.add_facet_field "member_of_team_ids_ssim", label: "Team", helper_method: :collection_title_by_id
        end
      end
      configure_facets

      def index
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

      def search_builder_class
        Morphosource::Users::MyMediaSearchBuilder
      end

      private

      def search_action_url(*args)
        main_app.my_media_index_path(*args)
      end

      def save_tab
        @tab = :media
      end

    end
  end
end
