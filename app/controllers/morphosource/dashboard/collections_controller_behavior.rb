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

          action = @_params["action"]
          if @collection.team?
            case action
            when "update"
              redirect_to team_update_path(@collection), status: 303
            when "edit"
              redirect_to team_edit_path(@collection)
            end
          elsif @collection.project?
            case action
            when "update"
              redirect_to project_update_path(@collection)
            when "edit"
              redirect_to project_edit_path(@collection)
            end
          end
        end
    end
  end
end
