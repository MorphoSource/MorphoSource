module Morphosource
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    # needed for some faceting behavior
    include Hydra::Catalog
    include Blacklight::AccessControls::Catalog
    include Blacklight::Base
    include Hyrax::CollectionsControllerBehavior
    include Morphosource::CollectionsControllerExportBehavior

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

    def presenter_class
      @collection.presenter_class
    end

    def show
      @tab = tab
      # save abilities so we won't have to check multiple times in views.
      @can_edit = current_ability.can? :edit, @collection
      @can_deposit = current_ability.can? :deposit, @collection
      presenter
      @object_ids = collection_object_ids
      (@response, @document_list) = query_solr
      publication_settings_nag
      query_collection_counts
      query_collection_members

      respond_to do |format|
        format.html { store_preferred_view }
      end
    end

    def about
      @tab = :about
      presenter
      @object_ids = collection_object_ids
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
        collection_type = @presenter&.human_readable_type&.downcase || "collection"
        flash[:alert] = "Your #{collection_type} is not published, but you have one or more media that are published. Publishing this #{collection_type} will increase the visibility of your published media, and will not affect the visibility of any private media you may have in the #{collection_type}. Select Edit to control publication settings." if private_project_published_media?
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
      end

      def authorize_collection
        authorize! :read, @collection
        rescue CanCan::AccessDenied
          redirect_to root_url, alert: 'You are not authorized to access this collection.'
      end

      def redirect_to_collection_type
        return unless (@_request.fullpath.include?('/collections/') && @collection.present?)
        remove_extra_params
        if @_request.fullpath.include? '/biological_specimens'
          redirect_to main_app.send("#{@collection.collection_type.machine_id}_specimens_path", request.parameters)
        elsif @_request.fullpath.include? '/cultural_heritage_objects'
          redirect_to main_app.send("#{@collection.collection_type.machine_id}_chos_path", request.parameters)
        elsif @_request.fullpath.include? '/about'
          redirect_to main_app.send("#{@collection.collection_type.machine_id}_about_path", request.parameters)
        else
          redirect_to main_app.send("#{@collection.collection_type.machine_id}_path", request.parameters)
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

      def collection_object_ids
        repository.blacklight_config.max_per_page = 999999
        response = repository.search(media_objects_search_builder_class.new(scope: self, collection: @collection).rows(999999)).response
        response["docs"].map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
      end

      # override Hyrax::CollectionsControllerBehavior - member_works isn't necessary
      def query_collection_members
        member_subcollections if collection.collection_type.nestable?
        parent_collections if collection.collection_type.nestable? && action_name == 'show'
      end

      def query_collection_counts
        @media_count ||= collection_media_count
        @specimen_count ||= collection_specimen_count
        @cho_count ||= collection_cho_count
      end

      def collection_media_count
        search_builder = media_count_search_builder_class.new(scope: self, collection: @collection).rows(999999)
        repository.search(search_builder.query).response["numFound"].to_i
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

      def create_access_facet
        return unless current_user.present?
        id = current_user.ms_id
        g = current_user.groups
        g_or = g.join(' OR ')

        config = repository.blacklight_config
        return if config.facet_fields['access'].present?
        config.add_facet_field 'access', label: 'Access', query: {
          edit: {
            label: 'Edit',
            fq: "(edit_access_group_ssim:(#{g_or}) OR (edit_access_person_ssim:#{id}))" },
          # media where current user has download access
          download: {
            label: 'Download',
            fq: "(download_access_group_ssim:(#{g_or}) OR (download_access_person_ssim:#{id}) NOT edit_access_person_ssim:#{id} NOT edit_access_group_ssim:(#{g_or}))" },
          # media where current user has read access
          view: {
            label: 'View',
            fq: "(read_access_group_ssim:(#{(['public'] + g).join(' OR ')}) OR (read_access_person_ssim:#{id}) NOT edit_access_person_ssim:#{id} NOT edit_access_group_ssim:(#{g_or}) NOT download_access_group_ssim:(#{g_or}) NOT download_access_person_ssim:#{id})"}
          }
        end

  end
end
