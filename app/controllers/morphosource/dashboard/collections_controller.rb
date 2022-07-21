module Morphosource
  module Dashboard
    class CollectionsController < ApplicationController
      # include Blacklight::AccessControls::Catalog
      include Blacklight::Base
      # include Hyrax::BreadcrumbsForCollections
      # include Morphosource::CollectionHelper

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class

      copy_blacklight_config_from(CatalogController)


      with_themed_layout 'morphosource_dashboard'

      # skip_load_and_authorize_resource instance_name: :collection

      before_action :load_collection

      self.presenter_class = Hyrax::TeamPresenter
      # The search builder to find the collection
      self.single_item_search_builder_class = Hyrax::SingleCollectionSearchBuilder

      self.form_class = Hyrax::Forms::CollectionForm


      def edit
        presenter
        @media_count = collection_media.count
        form
        # super
      end

      def presenter
        @presenter ||= begin
          # Query Solr for the collection.
          # run the solr query to find the collection members
          response = repository.search(single_item_search_builder.query)
          curation_concern = response.documents.first
          raise CanCan::AccessDenied unless curation_concern
          presenter_class.new(curation_concern, current_ability)
        end
        end


      def after_create
        form
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
        respond_to do |format|
          ActiveFedora::SolrService.commit
          format.html { redirect_to hyrax.edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: hyrax.dashboard_collection_path(@collection) }
        end
      end

      def set_default_permissions
        if @collection.type_assigns_groups?
          set_morphosource_permissions
        else
          additional_grants = @participants # Grants converted from older versions (< Hyrax 2.1.0) where share was edit or read access instead of managers, depositors, and viewers
          Hyrax::Collections::PermissionsCreateService.create_default(collection: @collection, creating_user: current_user, grants: additional_grants)
        end
      end

      def set_morphosource_permissions
        @collection.create_collection_groups
        @collection.copy_parent_membership(params[:parent_id]) unless params[:parent_id].nil?
        Morphosource::Collections::PermissionsCreateService.create_default(collection: @collection)
      end

      private

       def load_collection
          @curation_concern ||= params[:collection_id].present? ? ::Collection.find(params[:collection_id]) : ::Collection.find(params[:id])
          @collection ||= @curation_concern
          authorize! :edit, @collection
          rescue CanCan::AccessDenied
            redirect_to root_url, alert: 'You are not authorized to access this collection.'
        end


        def collection_media
          Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{@collection.id}")
        end

        def form
          @form ||= form_class.new(@collection, current_ability, repository)
        end

        def single_item_search_builder
         single_item_search_builder_class.new(self).with(params.except(:q, :page))
       end
    end
  end
end
