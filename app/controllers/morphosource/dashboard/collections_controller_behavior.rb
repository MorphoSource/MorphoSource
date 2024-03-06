module Morphosource
  module Dashboard
    module CollectionsControllerBehavior
      extend ActiveSupport::Concern

      include Morphosource::CollectionsControllerBehavior
      # include collection type paths
      include Morphosource::CollectionHelper

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
            redirect_to update_collection_path(@collection), flash: @flashes
          when "edit"
            redirect_to collection_edit_path(@collection), flash: @flashes
          end
        end

        # convert MediaList to :media_list
        def snake_case_collection_class
          collection_class.to_s.underscore.to_sym
        end

        def collection_params
          form_class.model_attributes(params[snake_case_collection_class])
        end

        def member_params
          params.dig(snake_case_collection_class, :members)
        end

        def thumbnail_params
          params.dig(snake_case_collection_class, :representative_id)
        end

        def member_subcollections
          docs = Morphosource::SolrService.new.get_docs("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{@collection.id}")
          docs.each do |doc|
            media_count = Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{doc['id']}").count
            doc.merge!({"media_count" => media_count})
          end
        end

    end
  end
end
