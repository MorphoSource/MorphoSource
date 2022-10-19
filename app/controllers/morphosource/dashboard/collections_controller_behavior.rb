module Morphosource
  module Dashboard
    module CollectionsControllerBehavior
      extend ActiveSupport::Concern

      include Morphosource::CollectionsControllerBehavior

      included do
        # This is needed as of BL 3.7
        copy_blacklight_config_from(::CatalogController)

        class_attribute :presenter_class,
                        :form_class,
                        :single_item_search_builder_class

        self.presenter_class = Morphosource::CollectionPresenter

        # The search builder to find the collection
        self.single_item_search_builder_class = Hyrax::SingleCollectionSearchBuilder
      end

      private

        def redirect_to_collection_type
          return unless @_request.fullpath.include? '/collections/'

          @flashes = flash.instance_variable_get(:@flashes)
          action = @_params["action"]
          case action
          when "update"
            redirect_to collection_update_path(@collection), flash: @flashes
          when "edit"
            redirect_to collection_edit_path(@collection), flash: @flashes
          end
        end

        def collection_edit_path(collection)
          collection.team? ? team_edit_path(collection) : project_edit_path(collection)
        end

        def collection_update_path(collection)
          collection.team? ? update_team_path(collection) : update_project_path(collection)
        end

        def collection_members_path(collection)
          collection.team? ? team_members_path(collection) : project_members_path(collection)
        end
    end
  end
end
