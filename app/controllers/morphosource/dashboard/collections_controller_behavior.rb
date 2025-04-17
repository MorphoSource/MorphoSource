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
            redirect_to helpers.update_collection_path(@collection), flash: @flashes
          when "edit"
            redirect_to helpers.collection_edit_path(@collection), flash: @flashes
          end
        end

        # convert MediaList to :media_list
        def snake_case_collection_class
          collection_class.to_s.underscore.to_sym
        end

        def collection_params
          Rails.logger.error("COLLECTION_PARAMS_CREATION: ")
          Rails.logger.error("PARAMS: #{params}")
          Rails.logger.error("FORM_CLASS: #{form_class}")
          Rails.logger.error("SNAKE_CASE_COLLECTION_CLASS: #{snake_case_collection_class}")
          Rails.logger.error("PARAMS_SNAKE_CASE_COLLECTION_CLASS: #{params[snake_case_collection_class]}")
          Rails.logger.error("FORM_CLASS.MODEL_ATTRIBUTES_PARAMS_NAKE_CASE_COLLECTION_CLASS: #{form_class.model_attributes(params[snake_case_collection_class])}")

          puts "COLLECTION_PARAMS_CREATION: "
          puts "PARAMS: #{params}"
          puts "FORM_CLASS: #{form_class}"
          puts "SNAKE_CASE_COLLECTION_CLASS: #{snake_case_collection_class}"
          puts "PARAMS_SNAKE_CASE_COLLECTION_CLASS: #{params[snake_case_collection_class]}"
          puts "FORM_CLASS.MODEL_ATTRIBUTES_PARAMS_NAKE_CASE_COLLECTION_CLASS: #{form_class.model_attributes(params[snake_case_collection_class])}"

          form_class.model_attributes(params[snake_case_collection_class])
        end

        def member_params
          params.dig(snake_case_collection_class, :members)
        end

        def thumbnail_params
          params.dig(snake_case_collection_class, :representative_id)
        end

        def member_subcollections
          subcollections = Morphosource::SolrService.new.get_docs("has_model_ssim:Collection AND member_of_collection_ids_ssim:#{@collection.id}")
          # add media count to each subcollection solr hit
          subcollection_media_counts = project_media_counts
          subcollections.each { |doc| doc.merge!({"media_count" => subcollection_media_counts[doc['id']]}) }
        end

        # return a hash of project id => media count
        def project_media_counts
          self.blacklight_config["facet_fields"] = {}
          self.blacklight_config.add_facet_field "project", field: "member_of_project_ids_ssim"
          search_builder = Morphosource::Catalog::MediaCatalogSearchBuilder.new(self)
          response = Blacklight::Solr::Repository.new(MediaCatalogController.new.blacklight_config).search(search_builder.query)
          Hash[*response["facet_counts"]["facet_fields"]["member_of_project_ids_ssim"]]
        end
    end
  end
end
