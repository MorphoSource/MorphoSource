# helper methods for teams and project collection show and edit pages
module Morphosource
  module CollectionHelper
    include MediaFinderHelper

    def ms_collection_view_link(id, view)
      current_uri = path_info
      if current_uri.include?("dashboard/collections")
        if action_name == 'edit'
          link = edit_dashboard_collection_path(id, view)
        else
          link = dashboard_collection_path(id, view)
        end
      else
        link = collection_path(id, view)
        if current_uri.include?("teams")
          # todo: fix team_path route 
          # link = team_path(id)
          link["collections"] = "teams" # replace "collection' with "teams"
        elsif current_uri.include?("projects")
          link["collections"] = "projects"
        end
      end
      link.html_safe
    end

    def filter_params(prefix, params)
      return_params = {}
      temp_params = params.select{ |k,v| k.match(/^#{prefix}/) }.select{ |k,v| v.present? }
      temp_params.each do |k,v|
        return_params[k.sub(prefix, '')] = v
      end
      return_params
    end

    def hidden_params_for_filters(prefix)
      hidden_params = {}
      params = request_params
      view =  params['view'] || 'list'
      #todo: might also merge the filter params here later.  For now just add the view param
      #filters = filter_params(prefix, params)
      hidden_params.merge!({'view' => view })
      html = ''
      hidden_params.map do |k,v|
        html += '<input type="hidden" name="' + k + '" value="' + v + '" />'
      end
      html.html_safe
    end

    def request_params
      request.params
    end

    def path_info 
      request.env['PATH_INFO']
    end

    def bso_tab_url(id)
      page = ''
      page = '?page=' + request_params['page'] if request_params['page'].present?
      '/projects/specimens/' + id + page
    end

    def prepare_docs_and_filters_for_media(collection)
      @visibility_options = []
      @pub_status_options = []
      @media_type_options = []
      @organization_options = []

      #@team_project_options = @subcollection_docs.map{|p| p.title}.flatten
      @team_project_options = @subcollection_docs.map(&:title).flatten # [] for projects

      extras_for_filter = {'source_of_result' => collection.collection_type.title.downcase}

      @paged_media_member_docs = paginated_media_item_list

      @media_extras = get_media_extras(@paged_media_member_docs, extras_for_filter)
      # save the item IDs in the team bucket, for determining the origin  

@media_member_docs = @member_docs

@media_member_count = @member_docs.length
@bso_member_count = 999
@cho_member_count = 0

      # add items from team bucket
      @team_bucket_media_id_list = @media_member_docs.map{|d| d.id}

#      if collection.team? 
#        # add items from team projects
#        @subcollection_docs.each do |project_doc|
#          @member_docs_from_projects = media_from_team_project(project_doc)
#          extras_for_filter = {'source_of_result' => 'team_project', 'team_project_title' => project_doc.title.first}
#          @media_member_docs_from_projects, @media_extras_from_projects, 
#            @bso_member_docs_from_projects, @bso_extras_from_projects, 
#              @cho_member_docs_from_projects, @cho_extras_from_projects = get_medias_and_objects(@member_docs_from_projects, extras_for_filter)
#
#          @media_member_docs += @media_member_docs_from_projects
#          @bso_member_docs += @bso_member_docs_from_projects
#          @cho_member_docs += @cho_member_docs_from_projects
#          @media_extras += @media_extras_from_projects
#          @bso_extras += @bso_extras_from_projects
#          @cho_extras += @cho_extras_from_projects
#        end

#        if collection.organization.present?
#          # add items from linked org
#          @member_docs_from_linked_org = media_from_linked_organization(collection.organization)
#          extras_for_filter = {'source_of_result' => 'linked_org'}
#          @media_member_docs_from_linked_org, @media_extras_from_linked_org, 
#            @bso_member_docs_from_linked_org, @bso_extras_from_linked_org, 
#              @cho_member_docs_from_linked_org, @cho_extras_from_linked_org = get_medias_and_objects(@member_docs_from_linked_org, extras_for_filter)

#          @media_member_docs += @media_member_docs_from_linked_org
#          @bso_member_docs += @bso_member_docs_from_linked_org
#          @cho_member_docs += @cho_member_docs_from_linked_org
#          @media_extras += @media_extras_from_linked_org
#          @bso_extras += @bso_extras_from_linked_org
#          @cho_extras += @cho_extras_from_linked_org
#        end

#      end        

#      @bso_member_docs = dedup(@bso_member_docs) if @bso_member_docs.present?
#      @cho_member_docs = dedup(@cho_member_docs) if @cho_member_docs.present?
      @media_member_count = @member_docs.length
#      @bso_member_count = @bso_member_docs&.length || 0
#      @cho_member_count = @cho_member_docs&.length || 0

#      @paged_media_member_docs = paginated_media_item_list
      @media_total_pages = media_total_pages
#      @paged_bso_member_docs = paginated_bso_item_list
#      @bso_total_pages = bso_total_pages
#      @paged_cho_member_docs = paginated_cho_item_list
#      @cho_total_pages = cho_total_pages

      @visibility_options = @visibility_options.uniq
      @pub_status_options = @pub_status_options.uniq
      @media_type_options = @media_type_options.uniq
      @organization_options = @organization_options.uniq
 #     @bso_source_options = @bso_source_options.uniq
    end

    def total_media_count(id)
      # todo: will need to optimize this 
      media = Media.find(id)
      @parent_media_id_list = parent_media_ids(media, 5, []).flatten.uniq
      @child_media_id_list = child_media_ids(media, 5, []).flatten.uniq
      @sibling_media_id_list = sibling_media_ids(media, []).flatten.uniq
      total_media_count = 1 + @parent_media_id_list.length +
                          @child_media_id_list.length + 
                          @sibling_media_id_list.length
      total_media_count
    end

    def cached_total_media_count(id)
      Rails.cache.fetch("/cached_total_media_count/#{id}", expires_in: 24.hours) do
        total_media_count(id)
      end
    end

    def get_media_extras(docs, extras)
      media_extras = []

      media_filter_params = filter_params('m_', params)

      docs.each do |doc|

          # if the media comes from linked organization, determine the origin:
          # origin = team if it’s in the team, and origin = org if it’s not in the team
          origin = 'Team'
          if extras['source_of_result'] == 'linked_org'
            unless @team_bucket_media_id_list.include? doc.id 
              origin = 'Org.'
            end
          end
          m_visibility_to_compare = media_filter_params['visibility'] || doc.visibility
          m_publication_status_to_compare = media_filter_params['pub_status'] || correct_fileset_visibility(doc.fileset_visibility)
          m_media_type_to_compare = media_filter_params['media_type'] || doc.media_type.first
          m_origin_to_compare = media_filter_params['origin'] || origin

          this_media_extras = { 'id' => doc.id, 'origin' => origin }

          # get BSO and CHO
          po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
          if po_doc.present?
            this_media_extras['po_title'] = po_doc.title&.first




            if po_doc.hydra_model == BiologicalSpecimen
              taxonomy = Morphosource::TaxonomySearchService.call({ 'member_ids' => po_doc.id})&.first
              this_media_extras['po_taxonomy'] = taxonomy.title&.first if taxonomy.present? && taxonomy.title.present?
            end
          end

          # filter media
          if doc.visibility == m_visibility_to_compare &&
              correct_fileset_visibility(doc.fileset_visibility) == m_publication_status_to_compare &&
              doc.media_type.first == m_media_type_to_compare &&
              origin == m_origin_to_compare
            
            media_extras << this_media_extras.merge(extras)
            @visibility_options << doc.visibility
            @pub_status_options << correct_fileset_visibility(doc.fileset_visibility)
            @media_type_options << doc.media_type.first
          end 
          # / filter media


      end # / docs.each

      return media_extras
    end

    def prepare_docs_and_filters_for_po(collection)
      @bso_visibility_options = []
      @bso_source_options = []
      @cho_visibility_options = []

      extras_for_filter = {'source_of_result' => collection.collection_type.title.downcase}
      @bso_member_docs, @bso_extras, 
        @cho_member_docs, @cho_extras = get_objects_from_media(@member_docs, extras_for_filter)

      @bso_member_docs = dedup(@bso_member_docs) if @bso_member_docs.present?
      @cho_member_docs = dedup(@cho_member_docs) if @cho_member_docs.present?
      @bso_member_count = @bso_member_docs&.length || 0
      @cho_member_count = @cho_member_docs&.length || 0

      @paged_bso_member_docs = paginated_bso_item_list
      @bso_total_pages = bso_total_pages
      @paged_cho_member_docs = paginated_cho_item_list
      @cho_total_pages = cho_total_pages

      @bso_source_options = @bso_source_options.uniq
    end

    def get_objects_from_media(docs, extras)
      bso_documents = []
      cho_documents = []
      bso_extras = []
      cho_extras = []

      bso_filter_params = filter_params('b_', params)
      cho_filter_params = filter_params('c_', params)

      docs.each do |doc|

          # if the media comes from linked organization, determine the origin:
          # origin = team if it’s in the team, and origin = org if it’s not in the team
          origin = 'Team'
          if extras['source_of_result'] == 'linked_org'
            unless @team_bucket_media_id_list.include? doc.id 
              origin = 'Org.'
            end
          end
          # get BSO and CHO
          po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
          if po_doc.present?
            if po_doc.hydra_model == BiologicalSpecimen
              bso_documents << po_doc unless bso_documents.include? po_doc
              bso_extras << { 'id' => po_doc.id, 'origin' => origin, 'media_count' => cached_total_media_count(doc.id) }.merge(extras) 
            elsif po_doc.hydra_model == CulturalHeritageObject
              cho_documents << po_doc unless cho_documents.include? po_doc
              cho_extras << { 'id' => po_doc.id, 'origin' => origin, 'media_count' => cached_total_media_count(doc.id) }.merge(extras) 
            end
          end

      end # / docs.each

      return bso_documents.compact, bso_extras,
                 cho_documents.compact, cho_extras
    end

    def correct_fileset_visibility(status)
      access = status&.first
      case
      when access == "open"
        "open"
      when access == "restricted_download"
        "restricted"
      when access == "preview_only"
        "preview"
      when access == "hidden"
        "hidden"
      else
        "private"
      end
    end

    def get_medias_and_objects_bak(docs, extras)
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
          # if the media comes from linked organization, determine the origin:
          # origin = team if it’s in the team, and origin = org if it’s not in the team
          origin = 'Team'
          if extras['source_of_result'] == 'linked_org'
            unless @team_bucket_media_id_list.include? doc.id 
              origin = 'Org.'
            end
          end
          m_visibility_to_compare = media_filter_params['visibility'] || work.visibility
          m_publication_status_to_compare = media_filter_params['pub_status'] || work.publication_status
          m_media_type_to_compare = media_filter_params['media_type'] || work.media_type.first
          m_origin_to_compare = media_filter_params['origin'] || origin

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
              b_origin_to_compare = bso_filter_params['origin'] || origin
              
              if bso.visibility == b_visibility_to_compare &&
                  bso_source == b_source_to_compare &&
                  bso_organization == b_organization_to_compare &&
                  origin == b_origin_to_compare

                bso_documents << bso_doc
                bso_extras << bso_extra
                bso_extras << { 'id' => bso_doc.id, 'origin' => origin }.merge(extras) 
                @bso_visibility_options << bso.visibility
                @bso_source_options << bso_source
              end
            end
          end # / if bso_doc present

          if cho_doc.present?
            cho = CulturalHeritageObject.find(cho_doc.id)

            unless cho_documents.any? {|h| h['id'] == cho_doc.id}
              # filter
              c_visibility_to_compare = cho_filter_params['visibility'] || cho.visibility
              c_origin_to_compare = cho_filter_params['origin'] || origin
              
              if cho.visibility == c_visibility_to_compare &&
                origin == c_origin_to_compare
                
                cho_documents << cho_doc 
                cho_extras << cho_extra
                cho_extras << { 'id' => cho_doc.id, 'origin' => origin }.merge(extras) 
                @cho_visibility_options << cho.visibility
              end
            end
          end # / if cho_doc present

          m_organization_to_compare = media_filter_params['organization'] || bso_organization
          m_team_project_to_compare = media_filter_params['team_project'] || extras['team_project_title']
          # filter media
          if work.visibility == m_visibility_to_compare &&
              work.publication_status == m_publication_status_to_compare &&
              work.media_type.first == m_media_type_to_compare &&
              bso_organization == m_organization_to_compare &&
              extras['team_project_title'] == m_team_project_to_compare &&
              origin == m_origin_to_compare
            
            media_documents << doc
            media_extras << { 'id' => doc.id, 'origin' => origin }.merge(extras)
            @visibility_options << work.visibility
            @pub_status_options << work.publication_status
            @media_type_options << work.media_type.first
          end 
          # / filter media

        end
      end # / docs.each

      return media_documents.compact, media_extras, 
               bso_documents.compact, bso_extras,
                 cho_documents.compact, cho_extras
    end

    def publication_status_label(value)
      case value
      when 'open'
        display_value = "Open Download"
      when 'restricted'
        display_value = "Restricted Download"
      when 'preview_only'
        display_value = "No Download"
      when 'hidden'
        display_value = "Hidden"
      when 'private'
        display_value = "Private"
      when 'embargo'
        display_value = "Embargo"
      when 'lease'
        display_value = "Lease"
      else
        display_value = value
      end
      display_value
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

    def media_from_linked_organization(organization)
      media_list = []
      # get all media from the linked org
      organization.outside_media.each do |media|
        media_doc = SolrDocument.new(media.to_solr) 
        media_list << media_doc
      end
      media_list
    end

    def physical_object_solr_from_media_bak(media_id)
      # this method returns the solr doc (and other details) of a PO associated with the media ID
      bso_work, bso_extra, cho_work, cho_extra = physical_object_from_media(media_id)
      bso_doc = SolrDocument.new(bso_work.to_solr) if bso_work.present?
      cho_doc = SolrDocument.new(cho_work.to_solr) if cho_work.present?
      return bso_doc, bso_extra, cho_doc, cho_extra
    end

    def physical_object_from_media_bak(id)
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
        @imaging_event = ImagingEvent.where('member_ids_ssim' => @processing_events.first.id).first
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
