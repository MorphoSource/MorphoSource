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

    def query_collection_information
      @collection_information = Morphosource::Collections::CollectionInformationService.call(
        collection.id, collection.team?
      )
      @collection_counts = @collection_information['counts'] ||= {}
      @collection_media_groups = @collection_information['media_groups'] ||= {}
      @collection_bso_groups = @collection_information['bso_groups'] ||= {}
      @collection_cho_groups = @collection_information['cho_groups'] ||= {}
    end

    def media_filter_params
      Morphosource::Collections::CollectionFilterService.solrize_filter_params(
        collection.id,
        filter_params('m_', params)
      )
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

    def prepare_docs_and_filters(collection)
      @visibility_options = []
      @organization_options = []
      @bso_visibility_options = []
      @bso_source_options = []
      @cho_visibility_options = []

      # add items from team bucket
      extras_for_filter = {'source_of_result' => collection.collection_type.title.downcase}
      @media_member_docs, @media_extras, @bso_member_docs, @bso_extras, 
        @cho_member_docs, @cho_extras = get_medias_and_objects(@member_docs, extras_for_filter)
      # save the item IDs in the team bucket, for determining the origin  
      @team_bucket_media_id_list = @media_member_docs.map{|d| d.id}

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

        if collection.organization.present?
          # add items from linked org
          @member_docs_from_linked_org = media_from_linked_organization(collection.organization)
          extras_for_filter = {'source_of_result' => 'linked_org'}
          @media_member_docs_from_linked_org, @media_extras_from_linked_org, 
            @bso_member_docs_from_linked_org, @bso_extras_from_linked_org, 
              @cho_member_docs_from_linked_org, @cho_extras_from_linked_org = get_medias_and_objects(@member_docs_from_linked_org, extras_for_filter)

          @media_member_docs += @media_member_docs_from_linked_org
          @bso_member_docs += @bso_member_docs_from_linked_org
          @cho_member_docs += @cho_member_docs_from_linked_org
          @media_extras += @media_extras_from_linked_org
          @bso_extras += @bso_extras_from_linked_org
          @cho_extras += @cho_extras_from_linked_org
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

      @bso_source_options = @bso_source_options.uniq
    end

    def get_medias_and_objects(docs, extras)
      media_documents = []
      bso_documents = []
      cho_documents = []
      media_extras = []
      bso_extras = []
      cho_extras = []

      bso_filter_params = filter_params('b_', params)
      cho_filter_params = filter_params('c_', params)

      docs.each do |doc|
        if doc.hydra_model == Media
          # if the media comes from linked organization, determine the origin:
          # origin = team if it’s in the team, and origin = org if it’s not in the team
          origin = 'Team'
          if extras['source_of_result'] == 'linked_org'
            unless @team_bucket_media_id_list.include? doc.id 
              origin = 'Org.'
            end
          end
          
          this_media_extras = { 'id' => doc.id, 'origin' => origin }

          # get BSO and CHO
          po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
          if po_doc.present?
            this_media_extras['po_title'] = po_doc.title&.first
            if po_doc.hydra_model == BiologicalSpecimen
              taxonomy = Morphosource::TaxonomySearchService.call({ 'member_ids' => po_doc.id})&.first
              this_media_extras['po_taxonomy'] = taxonomy.title&.first if taxonomy.present? && taxonomy.title.present?
              bso_documents << po_doc unless bso_documents.include? po_doc
              bso_extras << { 'id' => po_doc.id, 'origin' => origin }.merge(extras) 
            elsif po_doc.hydra_model == CulturalHeritageObject
              cho_documents << po_doc unless cho_documents.include? po_doc
              cho_extras << { 'id' => po_doc.id, 'origin' => origin }.merge(extras) 
            end
          end
   
          media_documents << doc
          media_extras << this_media_extras.merge(extras)

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
      when 'restricted_download'
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

    def media_type_label(value)
      case value
      when 'CTImageSeries'
        'CT Image Series'
      else
        value.underscore.titleize
      end
    end

    def origin_label(value)
      case value
      when 'team_organization'
        'Organization Linked To Team'
      when 'team_collection'
        'Direct Team Ownership'
      else
        ''
      end
    end

    def source_label(value)
      case value
      when 'idigbio'
        'iDigBio Aggregator'
      when 'user'
        'User Created'
      else
        ''
      end
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

    def organization_from_bso(bso)
      organization = Organization.where('member_ids_ssim' => bso.id).first
      organization
    end

  end
end
