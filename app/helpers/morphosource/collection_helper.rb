# helper methods for teams and project collection show and edit pages
module Morphosource
  module CollectionHelper

    def prepare_docs_and_filters(collection)

      @visibility_options = []
      @media_type_options = []
      @organization_options = []
      @bso_source_options = []
      #@team_project_options = @subcollection_docs.map{|p| p.title}.flatten
      @team_project_options = @subcollection_docs.map(&:title).flatten

      extras_for_filter = {'source_of_result' => collection.collection_type.title.downcase}
      @media_member_docs, @media_extras, @bso_member_docs, @bso_extras, 
        @cho_member_docs, @cho_extras = get_medias_and_objects(@member_docs, extras_for_filter)

      if collection.team? 
        # add items from team projects
        @subcollection_docs.each do |project_doc|
          @member_docs_from_projects = media_from_team_project(project_doc)

          extras_for_filter = {'source_of_result' => 'team_project', 'team_project_title' => project_doc.title.first}
          @media_member_docs_from_projects, @media_extras_from_projects, 
            @bso_member_docs_from_projects, @bso_extras_from_projects, 
              @cho_member_docs_from_projects, @cho_extras_from_projects = get_medias_and_objects(@member_docs_from_projects, extras_for_filter)

          @media_member_docs += @media_member_docs_from_projects
          @bso_member_docs += @bso_member_docs_from_projects
          @cho_member_docs += @cho_member_docs_from_projects
          @media_extras += @media_extras_from_projects
          @bso_extras += @bso_extras_from_projects
          @cho_extras += @cho_extras_from_projects
        end
      end        

      @bso_member_docs = dedup(@bso_member_docs) if @bso_member_docs.present?
      @cho_member_docs = dedup(@cho_member_docs) if @cho_member_docs.present?
      @media_member_count = @media_member_docs.length
      @bso_member_count = @bso_member_docs&.length || 0
      @cho_member_count = @cho_member_docs&.length || 0

      @paged_media_member_docs = paginated_media_item_list
      @media_total_pages = media_total_pages
      @paged_bso_member_docs = paginated_bso_item_list
      @bso_total_pages = bso_total_pages
      @paged_cho_member_docs = paginated_cho_item_list
      @cho_total_pages = cho_total_pages

      @visibility_options = @visibility_options.uniq
      @media_type_options = @media_type_options.uniq
      @organization_options = @organization_options.uniq
      @bso_source_options = @bso_source_options.uniq
    end

    def get_medias_and_objects(docs, extras)
      media_documents = []
      bso_documents = []
      cho_documents = []
      media_extras = []
      bso_extras = []
      cho_extras = []

      media_filter_params = filter_params('m_', params)
      bso_filter_params = filter_params('b_', params)
      cho_filter_params = filter_params('c_', params)

      docs.each do |doc|
        work = ::ActiveFedora::Base.find(doc.id)
        if work.class == Media      
          m_visibility_to_compare = media_filter_params['visibility'] || work.visibility
          m_media_type_to_compare = media_filter_params['media_type'] || work.media_type.first

          # get BSO and CHO
          bso_doc, bso_extra, cho_doc, cho_extra = physical_object_solr_from_media(doc.id)
          if bso_doc.present?
            bso = BiologicalSpecimen.find(bso_doc.id)
            organization = organization_from_bso(bso)

            if organization.present?
              bso_organization = organization.title.first 
              @organization_options << bso_organization
            else
              bso_organization = ''
            end
            # check if the ID already exists before adding
            unless bso_documents.any? {|h| h['id'] == bso_doc.id}
              # filter
              bso_source = display_source(bso)

              b_visibility_to_compare = bso_filter_params['visibility'] || bso.visibility
              b_source_to_compare = bso_filter_params['source'] || display_source(bso)
              b_organization_to_compare = bso_filter_params['organization'] || bso_organization
              
              if bso.visibility == b_visibility_to_compare &&
                  bso_source == b_source_to_compare &&
                  bso_organization == b_organization_to_compare

                bso_documents << bso_doc
                bso_extras << bso_extra
                bso_extras << { 'id' => bso_doc.id }.merge(extras) 
                @bso_source_options << bso_source
              end
            end
          end # / if bso_doc present

          if cho_doc.present?
            cho = CulturalHeritageObject.find(cho_doc.id)

            unless cho_documents.any? {|h| h['id'] == cho_doc.id}
              # filter
              c_visibility_to_compare = cho_filter_params['visibility'] || cho.visibility
              
              if cho.visibility == c_visibility_to_compare
                cho_documents << cho_doc 
                cho_extras << cho_extra
                cho_extras << { 'id' => cho_doc.id }.merge(extras) 
              end
            end
          end # / if cho_doc present

          m_organization_to_compare = media_filter_params['organization'] || bso_organization
          m_team_project_to_compare = media_filter_params['team_project'] || extras['team_project_title']

          # filter media
          if work.visibility == m_visibility_to_compare &&
              work.media_type.first == m_media_type_to_compare &&
              bso_organization == m_organization_to_compare &&
              extras['team_project_title'] == m_team_project_to_compare
            
            media_documents << doc
            media_extras << { 'id' => doc.id }.merge(extras) 
            @visibility_options << work.visibility
            @media_type_options << work.media_type.first
          end 
          # / filter media

        end
      end # / docs.each

      return media_documents.compact, media_extras, 
               bso_documents.compact, bso_extras,
                 cho_documents.compact, cho_extras
    end

    def media_from_team_project(project_doc)
      media_list = []
      # get all media from the project 
      project = Collection.find(project_doc.id)
      project.member_works.each do |work| 
        if work.class == Media
          media_doc = SolrDocument.new(work.to_solr) 
          media_list << media_doc
        end
      end
      media_list
    end

    #def media_from_team_projects(docs)
    #  media_list = []
    #  # get all media from each project 
    #  docs.each do |doc|
    #    project = Collection.find(doc.id)
    #    project.member_works.each do |work| 
    #      if work.class == Media
    #        media_doc = SolrDocument.new(work.to_solr) 
    #        media_list << media_doc
    #      end
    #    end
    #  end
    #  media_list
    #end

    def physical_object_solr_from_media(media_id)
      # this method returns the solr doc (and other details) of a PO associated with the media ID
      bso_work, bso_extra, cho_work, cho_extra = physical_object_from_media(media_id)
      bso_doc = SolrDocument.new(bso_work.to_solr) if bso_work.present?
      cho_doc = SolrDocument.new(cho_work.to_solr) if cho_work.present?
      return bso_doc, bso_extra, cho_doc, cho_extra
    end

    def physical_object_from_media(id)
      #find BSO or CHO assigned to the media id
      media = Media.find(id)

      # Get parent medias (all)
      # add current media id, then add child media ids.
      # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
      # so there is no need to traverse the tree
      @parent_media_id_list = parent_media_ids(media, 5, []).flatten.uniq
      @child_media_id_list = child_media_ids(media, 5, []).flatten.uniq
      @sibling_media_id_list = sibling_media_ids(media, []).flatten.uniq
      total_media_count = 1 + @parent_media_id_list.length +
                          @child_media_id_list.length + 
                          @sibling_media_id_list.length

      # get the top parent
      direct_parent_id = top_parent_media_id(media)
      #direct_parent_id_list = parent_media_ids(media, 1, []).flatten.uniq
      direct_parent_id_list = []
      if direct_parent_id.present?
        direct_parent_id_list << direct_parent_id
      end

      @is_absentee_parent = false

      this_media_list = [] << id
      # get members for this media combined with parents, ordered in reverse
      @this_media_and_parents_id_list = @parent_media_id_list << id
      # get processing event:  media < processing_event
      # then get processing event data: activity items, child/parent IDs and member presenters
      @processing_events = ProcessingEvent.where('member_ids_ssim' => @this_media_and_parents_id_list)
      @processing_event_count = @processing_events.count

      if direct_parent_id_list.length > 0
        # If a media has a parent work and is derived, then that media’s raw ancestor media work
        # (whether parent, grandparent, etc) should be connected to an IE from which metadata should be derived.
        target_media = Media.where('id' => direct_parent_id).first
      else
        target_media = media
        # check if this is a Derived media with "absentee parent" by checking if PE exists
        if @processing_event_count > 0
          @is_absentee_parent = true
        end
      end

      # Get the physical object type from:
      # Media < IE < PO
      # or
      # media < PE < IE < PO (for media with absentee parent)
      if @is_absentee_parent == true
        @imaging_event = ImagingEvent.where('member_ids_ssim' => processing_event_ids.first).first
      else
        @imaging_event = ImagingEvent.where('member_ids_ssim' => target_media.id).first
      end

      if @imaging_event.present?
        bso = BiologicalSpecimen.where('member_ids_ssim' => @imaging_event.id).first
        cho = CulturalHeritageObject.where('member_ids_ssim' => @imaging_event.id).first
      end
      bso_extra = {}
      cho_extra = {}

      if bso.present?
        bso_extra = { 'id' => bso.id, 'media_count' => total_media_count.to_s}
      elsif cho.present?
        cho_extra = { 'id' => cho.id, 'media_count' => total_media_count.to_s}
      end
      return bso, bso_extra, cho, cho_extra
    end

    def organization_from_bso(bso)
      organization = Organization.where('member_ids_ssim' => bso.id).first
      organization
    end

  end
end
