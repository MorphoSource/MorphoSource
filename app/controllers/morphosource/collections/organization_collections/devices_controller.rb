module Morphosource
  module Collections
    module OrganizationCollections
      class DevicesController < Morphosource::Collections::PhysicalObjectsController

        include Morphosource::Collections::OrganizationCollectionsControllerBehavior
        include Morphosource::Collections::OrganizationHelper

        # restrict to admins
        before_action :authorize_admin

        skip_load_and_authorize_resource only: [:show, :about, :facet, :devices_export], instance_name: :collection

        def search_builder_class
          Morphosource::Collections::OrganizationCollections::DevicesSearchBuilder
        end

        def media_count_search_builder_class
          Morphosource::Collections::OrganizationCollections::DeviceMediaSearchBuilder
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

        private

          # link for facet filters
          def search_action_url(*args)
            args&.first&.delete("collection_id")
            collection_type = @collection.collection_type.machine_id
            main_app.send("#{collection_type}_devices_path", @collection, *args)
          end

          # The url of the "more" link for additional facet values
          def search_facet_path(args = {})
            # args id is the solr facet
            # params id is the collection id
            args.merge!(request.params)
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