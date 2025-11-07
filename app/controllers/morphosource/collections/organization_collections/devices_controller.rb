module Morphosource
  module Collections
    module OrganizationCollections
      class DevicesController < Morphosource::Collections::PhysicalObjectsController

        include Morphosource::Collections::OrganizationCollectionsControllerBehavior
        include Morphosource::Collections::OrganizationCollectionHelper

        skip_load_and_authorize_resource only: [:show, :about, :facet, :devices_export], instance_name: :collection

        helper_method :search_action_for_dashboard

        def search_builder_class
          Morphosource::Collections::OrganizationCollections::DevicesSearchBuilder
        end

        def media_count_search_builder_class
          Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder
        end

        self.presenter_class = Morphosource::Collections::OrganizationPresenter

        def self.configure_facets
          configure_blacklight do |config|
            config.http_method = :post
            config.search_builder_class = self.new.search_builder_class
            # clear catalog facet fields
            config.facet_fields = {}
            config.add_facet_field "manufacturer", field: "creator_ssim", label: "Manufacturer", limit: 10
            config.add_facet_field "model", field: "title_ssi", label: "Model", limit: 10
            config.add_facet_field "modality", field: "modality_ssim", label: "Modality", limit: 10, helper_method: :modality_label
          end
        end
        configure_facets

        def search_action_for_dashboard
          main_app.organization_devices_path(@collection)
        end

        private

          # link for facet filters
          def search_action_url(*args)
            args&.first&.delete("collection_id")
            collection_type = @collection.collection_type.machine_id
            main_app.send("#{collection_type}_devices_path", @collection, *args)
          end

          # The url of the "more" link for additional facet values
          def search_facet_path(args = {})
            args.merge!(request.params)
            # args :id is the solr facet
            # params/args "id" is the collection id
            args.delete("id")
            collection_type = @collection.collection_type.machine_id
            main_app.send("#{collection_type}_devices_facet_path", @collection.id, args)
          end

          def tab
            :devices
          end
      end
    end
  end
end