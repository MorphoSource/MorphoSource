module Hyrax
  class BrowseTeamPresenter < CollectionPresenter

    #def initialize(solr_document, current_ability, request = nil)
    def initialize(solr_document, current_ability, coll_type)
      super
      @collection_type_title = coll_type
    end

    def team?
      @collection_type_title == 'Team'
    end

    def project?
      @collection_type_title == 'Project'
    end

    def get_media_po_counts_by_collection(collection_id)
      @total_media, @total_po = browse_service.total_media_and_po_by_collection(collection_id)
    end

    def browse_service
      @browse_service ||= Morphosource::BrowseService.new
    end

    def total_media
      @total_media
    end

    def total_po
      @total_po
    end

    def total_team_projects
      browse_service.total_team_projects_by_collection(id)
    end

    def project_team_title_link
      if member_of_collection_ids.present?
        collection = Collection.find(id)        
        renderer = Hyrax::Renderers::ShowcaseCollectionLinkRenderer.new(nil,nil)
        return renderer.collection_link(collection.first_parent)
      else
        return ""
      end
    end

    # Metadata Methods
    delegate :title, :description, :creator,
             :member_of_collection_ids, :linked_organization,
             to: :solr_document



  end
end
