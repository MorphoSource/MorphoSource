module Morphosource
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
    include Hyrax::CollectionsControllerBehavior

    included do
      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      self.presenter_class = Morphosource::CollectionPresenter

      # The search builder to find the collection
      self.single_item_search_builder_class = Hyrax::SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService
    end

    def show
      presenter
      (@response, @document_list) = query_solr
      query_collection_works
      remove_facets
      filter_facets
      gather_instance_variables
      query_collection_members
    end

    def about
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

      def load_collection
        @curation_concern ||= ::Collection.find(params[:id])
        @collection ||= @curation_concern

        # authorize! :read, @collection
        raise CanCan::AccessDenied unless (@curation_concern && current_ability.can?(:read, @curation_concern))
        rescue CanCan::AccessDenied
          redirect_to root_url, alert: 'You are not authorized to access this collection.'
      end

      def redirect_to_collection_type
        if @_request.fullpath.include? '/collections/'
          locale = params[:locale] ||= 'en'
          if @curation_concern.team?
            redirect_to collection_type_url("teams")
          elsif @curation_concern.project?
            redirect_to collection_type_url("projects")
          else
            return
          end
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
        member_subcollections if collection.collection_type.nestable?
        parent_collections if collection.collection_type.nestable? && action_name == 'show'
      end

      def query_collection_works
        if !@media_list.present? && !@media_count.present?
          @media_list, @media_count = collection_media
        end
        @specimen_count ||= collection_specimens
        @cho_count ||= collection_chos
      end

      def collection_media
        repository.blacklight_config.max_per_page = 999999
        search_builder = Morphosource::Collections::MediaSearchBuilder.new(scope: self, collection: @collection)
        media_list = repository.search(search_builder.rows(999999).query).response["docs"]
        media_count = media_list.count.to_s + ' Media'
        [media_list, media_count]
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
        media_list.map{ |m| m["media_physical_object_type_ssim"]&.first }.uniq
      end

      def search_builder
        # byebug
        search_builder_class.new(scope: self, collection: @curation_concern)
      end

      def tab
        :media
      end

  end
end
