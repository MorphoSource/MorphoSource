module Hyrax
  class MyTeamPresenter < CollectionPresenter
    # this presenter is for showing team in each row on dashboard my team listing page
    include Morphosource::CollectionHelper

    attr_writer :collection_type

    def initialize(solr_document, current_ability, request = nil)
      super
    end

    def membership(current_user)
      if collection.managers.include?(current_user)
        'Manager'
      elsif collection.editors.include?(current_user)
        'Editor'
      elsif collection.viewers.include?(current_user)
        'Viewer'
      elsif collection.downloaders.include?(current_user)
        'Downloader'
      elsif collection.depositors.include?(current_user)
        'Depositor'
      else
        ''
      end
    end

    def collection
      @collection ||= Collection.find(id)
    end

    def collection_type
      @collection_type ||= Hyrax::CollectionType.find_by_gid!(collection_type_gid)
    end

    def collection_type_title
      collection_type.title
    end

    def team?
      collection_type_title == 'Team'
    end

    def project?
      collection_type_title == 'Project'
    end

    def project_team_title_link
      #if @collection.first_parent.present?
      if member_of_collection_ids.present?
        collection = Collection.find(id)        
        renderer = Hyrax::Renderers::ShowcaseCollectionLinkRenderer.new(nil,nil)
        return renderer.collection_link(collection.first_parent)
      else
        return ""
      end
    end

    # Metadata Methods
    delegate :title, :description, :member_of_collection_ids,
             :linked_organization,
             to: :solr_document



  end
end
