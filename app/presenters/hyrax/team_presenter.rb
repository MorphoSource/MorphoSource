module Hyrax
  class TeamPresenter < CollectionPresenter
    #include MorphosourceHelper
    include Morphosource::CollectionHelper

    attr_reader :filter_projects, :subcollection_count, :search_form_url, :collection, :collection_managers, :collection_type_title, :specimens, 
      :organization,
      :organization_organization_type,
      :organization_title,
      :organization_institution_name,
      :organization_institution_code,
      :organization_collection_code,
      :organization_description,
      :organization_address,
      :organization_city,
      :organization_state_province,
      :organization_country,
      :organization_media_count,
      :organization_bso_count,
      :organization_cho_count

    attr_writer :collection_type

    def initialize(solr_document, current_ability, request = nil)
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

    def filter_projects(docs, params)
      project_filter_params = filter_params('p_', params)
      return docs if project_filter_params.empty?
      filtered_docs = []
      docs.each do |doc|
        collection = Collection.find(doc.id)
        visibility_to_compare = project_filter_params['visibility'] || collection.visibility
        if collection.visibility == visibility_to_compare
          filtered_docs << doc
        end
      end
      filtered_docs
    end

    def organization_object_counts(org)
      # get the media count, bso count, cho count
      # bso / cho count:
      # organization > bso/cho  
      # media count:
      # organization > bso/cho > IE > media 
      # todo: handle absentee parents?
      bso_count = 0
      cho_count = 0
      media_count = 0
      bso_works = BiologicalSpecimen.where('id' => org.member_ids)
      cho_works = CulturalHeritageObject.where('id' => org.member_ids)
      imaging_event_works = []
      if bso_works.present?
        bso_count = bso_works.length 
        bso_works.each do |po|
          imaging_event_works = (imaging_event_works + ImagingEvent.where('id' => po.member_ids)&.to_ary).uniq
        end
      end
      if cho_works.present?
        cho_count = cho_works.length 
        cho_works.each do |po|
          imaging_event_works = (imaging_event_works + ImagingEvent.where('id' => po.member_ids)&.to_ary).uniq
        end
      end
      if imaging_event_works.present?
        imaging_event_works.each do |ie|
          imaging_event = ImagingEvent.find(ie.id)
          media_work = Media.where('id' => imaging_event.member_ids)
          media_count += media_work.length if media_work.present?
        end
      end
      return media_count, bso_count, cho_count
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
        @organization_description = organization.description
        @organization_address = organization.address
        @organization_city = organization.city
        @organization_state_province = organization.state_province
        @organization_country = organization.country
        @organization_media_count, @organization_bso_count, @organization_cho_count =
          organization_object_counts(organization)
      end
    end

    # Metadata Methods
    delegate :title, :description, :creator, :contributor, :subject, :publisher, :keyword, :language, :embargo_release_date,
             :lease_expiration_date, :license, :date_created, :resource_type, :based_near, :related_url, :identifier, :thumbnail_path,
             :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
             :part, :media_type, 
             to: :solr_document


  
  end
end
