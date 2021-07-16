module Morphosource
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base

    include Hyrax::CollectionsControllerBehavior

    # include MorphosourceHelper

    included do
      # include the display_trophy_link view helper method
      # helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      # self.presenter_class = Hyrax::TeamPresenter
      self.presenter_class = Morphosource::CollectionPresenter

      # The search builder to find the collection
      self.single_item_search_builder_class = Hyrax::SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService
      # self.information_service_class = Morphosource::Collections::CollectionInformationService
    end

    def show
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @_request.fullpath.include? '/collections/'
        redirect_to_collection_type
        return
      end
      @collection = @curation_concern
      presenter
      (@response, @document_list) = query_solr
      query_collection_works
      filter_facets
      gather_instance_variables
      query_collection_members
    end

    def about
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @_request.fullpath.include? '/collections/'
        redirect_to_collection_type
        return
      end
      @collection = @curation_concern
      @tab = :about
      presenter
      query_collection_works
      gather_instance_variables
      query_collection_members
      render 'about'
    end

    private

      def gather_instance_variables
        @tab ||= tab
      end

      def redirect_to_collection_type
        # @curation_concern ||= ActiveFedora::Base.find(params[:id])
        locale = params[:locale] ||= 'en'
        if @curation_concern.team?
          redirect_to collection_type_url("teams")
        elsif @curation_concern.project?
          redirect_to collection_type_url("projects")
        else
          return
        end
      end

      def collection_type_url(plural_type)
        locale = params[:locale] ||= 'en'
        view = params[:view] ||= ''
        "/#{plural_type}/" + params[:id] + '?locale=' + locale + view
      end

      def query_solr
        search_results(params)
      end

      # override Hyrax::CollectionsControllerBehavior - member_works isn't necessary
      def query_collection_members
        # member_works
        member_subcollections if collection.collection_type.nestable?
        parent_collections if collection.collection_type.nestable? && action_name == 'show'
      end

      def query_collection_works
        collection_media
        collection_specimens
        collection_chos
      end

      def collection_media
        search_builder = Morphosource::Collections::MediaSearchBuilder.new(scope: self, collection: @collection)
        @media_list = repository.search(search_builder.rows(999999).query).response["docs"]
        @media_count = @media_list.count.to_s + ' Media'
      end

      def collection_specimens
        search_builder = Morphosource::Collections::SpecimensSearchBuilder.new(self)
        response = repository.search(search_builder.query)
        @specimen_count = response.response["numFound"].to_i
      end

      def collection_chos
        search_builder = Morphosource::Collections::ChosSearchBuilder.new(self)
        response = repository.search(search_builder.query)
        @cho_count = response.response["numFound"].to_i
      end

      def media_object_type(media_list)
        media_list.map{|m| m["media_physical_object_type_ssim"]&.first }.uniq
      end

  end
end
