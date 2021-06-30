module Hyrax
  class TeamPresenter < CollectionPresenter
    #include MorphosourceHelper
    #include Morphosource::CollectionHelper

    attr_reader :filter_projects, :subcollection_count, :search_form_url, :collection, :collection_managers, :collection_type_title, :specimens,
      :organization,
      :organization_organization_type,
      :organization_title,
      :organization_institution_name,
      :organization_institution_code,
      :organization_collection_code,
      :organization_recordset_id,
      :organization_description,
      :organization_related_url,
      :organization_address,
      :organization_city,
      :organization_state_province,
      :organization_postal_code,
      :organization_country,
      :organization_media_count,
      :organization_bso_count,
      :organization_cho_count

    attr_writer :collection_type

    def initialize(solr_document, current_ability, request = nil)
      byebug
      super
      @search_form_url = ''
      @collection = Collection.find(id)
      @collection_managers = manager_list(@collection.managers)
      set_organization_data
    end

    def membership(current_user)
      if @collection.managers.include?(current_user)
        'Manager'
      elsif @collection.editors.include?(current_user)
        'Editor'
      elsif @collection.viewers.include?(current_user)
        'Viewer'
      end
    end

    def manager_list(managers)
      ml = []
      managers.each do |m|
        renderer = Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer.new(nil,nil)
        ml << renderer.user_link(m)
      end
      ml.join(', ').html_safe
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

    def organization
      @collection.organization
    end

    def set_organization_data
      collection = Collection.find(id)
      organization = collection.organization
      if organization.present?
        @organization_title = organization.title
        @organization_organization_type = organization.organization_type
        @organization_institution_name = organization.institution_name
        @organization_institution_code = organization.institution_code
        @organization_collection_code = organization.collection_code
        @organization_recordset_id = organization.recordset_id
        @organization_description = organization.description
        @organization_related_url = organization.related_url
        @organization_address = organization.address
        @organization_city = organization.city
        @organization_state_province = organization.state_province
        @organization_postal_code = organization.postal_code
        @organization_country = organization.country
      end
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
    delegate :title, :description, :creator, :contributor, :subject, :publisher, :keyword, :language, :embargo_release_date,
             :lease_expiration_date, :license, :date_created, :resource_type, :based_near, :related_url, :identifier, :thumbnail_path,
             :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
             :part, :media_type, :member_of_collection_ids,
             to: :solr_document



  end
end
