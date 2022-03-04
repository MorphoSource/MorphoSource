module Morphosource
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    # needed for some faceting behavior
    include Hydra::Catalog
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
      @tab = tab
      presenter
      (@media_count, @object_ids) = collection_media
      (@response, @document_list) = query_solr
      publication_settings_nag
      query_collection_counts
      query_collection_members
      
      respond_to do |format|
        format.html { store_preferred_view }
        format.rss  { render :layout => false }
        format.atom { render :layout => false }
        format.csv  do
          redirect_to '/' unless current_user&.admin?
          (_, @csv_document_list) = query_solr_all_results
          @new_document_list = @csv_document_list.map { |d| d.to_semantic_values }
          csv_response_headers('Query')
        end
      end
    end

    def about
      @tab = :about
      presenter
      (@media_count, @object_ids) = collection_media
      query_collection_counts
      query_collection_members
      render 'about'
    end

    private

      def presenter
        @presenter ||= begin
          curation_concern = @curation_concern.present? ? SolrDocument.find(@curation_concern.id) : SolrDocument.find(params[:id])
          raise CanCan::AccessDenied unless (curation_concern && current_ability.can?(:read, curation_concern))
          presenter_class.new(curation_concern, current_ability)
        end
      end

      def publication_settings_nag
        flash[:alert] = "Your project or team is not published, but you have one or more media that are published. Publishing this project will increase the visibility of your published media, and will not affect the visibility of any private media you may have in the project or team. Select Edit to control publication settings." if private_project_published_media?
      end

      def private_project_published_media?
        @presenter.present? &&
        @response.present? &&
        current_ability.can?(:edit, @presenter.collection) &&
        (@presenter.visibility == 'restricted') &&
        ( (@response.aggregations["publication_status_ssi"]&.items || []).
          select{ |i|
            (i.value=="Open Download" || i.value=="Restricted Download")
          }.count >  0)
      end

      def load_collection
        @curation_concern ||= params[:collection_id].present? ? ::Collection.find(params[:collection_id]) : ::Collection.find(params[:id])
        @collection ||= @curation_concern
        authorize! :read, @collection
        rescue CanCan::AccessDenied
          redirect_to root_url, alert: 'You are not authorized to access this collection.'
      end

      def redirect_to_collection_type
        remove_extra_params
        if @_request.fullpath.include? '/collections/'
          if @collection.team?
            if @_request.fullpath.include? '/biological_specimens'
              redirect_to team_specimens_path(request.parameters)
            elsif @_request.fullpath.include? '/cultural_heritage_objects'
              redirect_to team_chos_path(request.parameters)
            else
              redirect_to team_media_path(request.parameters)
            end
          elsif @collection.project?
            if @_request.fullpath.include? '/biological_specimens'
              redirect_to project_specimens_path(request.parameters)
            elsif @_request.fullpath.include? '/cultural_heritage_objects'
              redirect_to project_chos_path(request.parameters)
            else
              redirect_to project_media_path(request.parameters)
            end
          else
            return
          end
        end
      end

      # cleans up url on redirects from the catalog or paging
      def remove_extra_params
        params = ["controller","action","id","locale"]
        params.each do |param|
          request.parameters.delete(param)
        end
      end

      def query_solr
        search_results(params)
      end

      def query_solr_all_results
        search_results(params.merge(return_all_fields: true))
      end

      def collection_media
        repository.blacklight_config.max_per_page = 999999
        response = repository.search(Morphosource::Collections::MediaObjectsSearchBuilder.new(scope: self, collection: @collection).rows(999999)).response
        media_count = response["numFound"].to_i
        object_ids = response["docs"].map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
        [media_count, object_ids]
      end

      # override Hyrax::CollectionsControllerBehavior - member_works isn't necessary
      def query_collection_members
        member_subcollections if collection.collection_type.nestable?
        parent_collections if collection.collection_type.nestable? && action_name == 'show'
      end

      def query_collection_counts
        @specimen_count ||= collection_specimen_count
        @cho_count ||= collection_cho_count
      end

      # count of specimens whose media is returned by collection_media
      def collection_specimen_count
        search_builder = Morphosource::Collections::SpecimensCountSearchBuilder.new(self)
        repository.search(search_builder.query).response["numFound"].to_i
      end

      # count of chos whose media is returned by collection_media
      def collection_cho_count
        search_builder = Morphosource::Collections::ChosCountSearchBuilder.new(self)
        repository.search(search_builder.query).response["numFound"].to_i
      end

      def search_builder
        search_builder_class.new(scope: self, collection: @curation_concern)
      end

      def tab
        :media
      end

  end
end
