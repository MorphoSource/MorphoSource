module Morphosource
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base

    include Hyrax::CollectionsControllerBehavior

    # include MorphosourceHelper

    included do
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      self.presenter_class = Hyrax::TeamPresenter

      # The search builder to find the collection
      self.single_item_search_builder_class = Hyrax::SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService
      self.information_service_class = Morphosource::Collections::CollectionInformationService
    end

    def show
      byebug
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      if @_request.fullpath.include? '/collections/'
        redirect_to_collection_type
        return
      end
      @collection = @curation_concern
      presenter
      (@response, @document_list) = query_solr
      gather_instance_variables
      query_collection_members
    end

    def media
      byebug
      @curation_concern ||= ActiveFedora::Base.find(params[:id])
      byebug
      if @_request.fullpath.include? '/collections/'
        redirect_to_collection_type
        return
      end
      @collection = @curation_concern
      byebug
      presenter
      byebug
      (@response, @document_list) = query_solr
      byebug
      gather_instance_variables
      byebug
      query_collection_members
    end

    def curation_concern
      byebug
      # Query Solr for the collection.
      # run the solr query to find the collection members
      response, _docs = search_service.search_results
      curation_concern = response.documents.first
      raise CanCan::AccessDenied unless curation_concern
      curation_concern
    end

    private

      def gather_instance_variables
        @media_member_count = @response.response["numFound"]
        @po_type = @document_list.map{|m| m["media_physical_object_type_ssim"]&.first }.uniq
        @tab = tab
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
        byebug
        search_results(params)
      end

      # def presenter
      #   byebug
      #   @presenter ||= begin
      #     presenter_class.new(@curation_concern, current_ability)
      #   end
      # end



  end
end
