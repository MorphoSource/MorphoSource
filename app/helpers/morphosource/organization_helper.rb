# helper methods for teams and project collection show and edit pages
module Morphosource
  module OrganizationHelper
    include MediaFinderHelper

    def show_org_url(id, tab)
      Rails.application.routes.url_helpers.show_organization_path(id) + "#" + tab
    end

    def ms_organization_view_link(id, view)
#      current_uri = path_info
#      if current_uri.include?("dashboard/collections")
#        if action_name == 'edit'
#          link = edit_dashboard_collection_path(id, view)
#        else
#          link = dashboard_collection_path(id, view)
#        end
#      else
#        link = collection_path(id, view)
#        if current_uri.include?("teams")
#          # todo: fix team_path route
#          # link = team_path(id)
#          link["collections"] = "teams" # replace "collection' with "teams"
#        elsif current_uri.include?("projects")
#          link["collections"] = "projects"
#        end
#      end
      link = Rails.application.routes.url_helpers.show_organization_path(id, view)
      link.html_safe
    end

    def ms_organization_view_link_qs(tab, filter_prefix)
      link = ""
      parsed_params = filter_params(filter_prefix, request_params)
      parsed_params.map do |k,v|
        link = link + '&' + k + '=' + v 
      end       
      link = link + "#" + tab if tab.present?
      link.html_safe
    end

    def query_organization_information
      @organization_information = organization_information_service.organization_information
#      @collection_counts = @collection_information['counts'] ||= {}
#      @collection_groups = @collection_information['collection_groups'] ||= {}

      @organization_media_groups = @organization_information['media_groups'] ||= {}
      @organization_bso_groups = @organization_information['bso_groups'] ||= {}
      @organization_cho_groups = @organization_information['cho_groups'] ||= {}
    end

    def organization_information_service
      @organization_information_service ||= information_service_class.new(curation_concern.id) 
    end

#def query_collection_information
#  @collection_information = organization_information_service.collection_information
#  @collection_counts = @collection_information['counts'] ||= {}
#  @collection_media_groups = @collection_information['media_groups'] ||= {}
#  @collection_bso_groups = @collection_information['bso_groups'] ||= {}
#  @collection_cho_groups = @collection_information['cho_groups'] ||= {}
#  @collection_object_ids = @collection_information['collection_object_ids'] ||= []
#  @collection_organization_object_ids = @collection_information['organization_object_ids'] ||= []
#end

    def media_filter_params
      organization_information_service.solrize_filter_params(filter_params('m_', params))
    end

    def bso_filter_params
      organization_information_service.solrize_filter_params(filter_params('b_', params))
    end

    def cho_filter_params
      organization_information_service.solrize_filter_params(filter_params('c_', params))
    end

    def filter_params(prefix, params)
      return_params = {}
      temp_params = params.select{ |k,v| k.match(/^#{prefix}/) }.select{ |k,v| v.present? }
      temp_params.each do |k,v|
        return_params[k] = v
      end
      return_params
    end

    def hidden_params_for_filters(prefix)
      hidden_params = {}
      params = request_params
      hidden_params.merge!({'view' => params['view']}) if params['view'].present?
      hidden_params.merge!({'rows' => params['rows']}) if params['rows'].present?
      hidden_params.merge!({'brows' => params['brows']}) if params['brows'].present?
      hidden_params.merge!({'crows' => params['crows']}) if params['crows'].present?
      html = ''
      hidden_params.map do |k,v|
        html += '<input type="hidden" name="' + k + '" value="' + v + '" />'
      end
      html.html_safe
    end

    def hidden_params_for_pagination(prefix)
      hidden_params = {}
      params = request_params
      hidden_params.merge!({'view' => params['view']}) if params['view'].present?
      html = ''
      hidden_params.map do |k,v|
        html += '<input type="hidden" name="' + k + '" value="' + v + '" />'
      end
      params.map do |k,v|
        html += '<input type="hidden" name="' + k + '" value="' + v + '" />' if k.include? prefix
      end
      html.html_safe
    end

    def request_params
      request.params
    end

    def path_info 
      request.env['PATH_INFO']
    end

    def bso_tab_url
      url_params = request_params.
        map { |k, v| "#{k}=#{v}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/dashboard/my/media/specimens?#{url_params}"
    end

    def cho_tab_url
      url_params = request_params.
        map { |k, v| "#{k}=#{v}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/dashboard/my/media/chos?#{url_params}"
    end

    def prepare_docs_and_filters_for_media
#      @po_type = "bso" # bso / cho
#      @is_team = collection.team?
      @visibility_options = []

#      @team_project_options = @subcollection_docs.map(&:title).flatten # [] for projects
      @bso_visibility_options = []
      @bso_source_options = []
      @cho_visibility_options = []

#      @members_count = @media_member_docs.length
#      @media_member_docs = @member_docs      
#      @media_member_count = @media_member_docs.length
#      
#      @paged_media_member_docs = paginated_media_item_list
#      @document_list = @paged_media_member_docs
      @media_extras = get_media_extras(@paged_media_member_docs)
    end

    def get_media_extras(docs)
      docs.map do |doc|
        this_media_extras = { 
          'id' => doc.id
        }
        # get BSO and CHO title
        po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
        if po_doc.present?
          this_media_extras['po_title'] = po_doc.title&.first
          if po_doc.hydra_model == BiologicalSpecimen
            @po_type = "bso"
            taxonomy = Morphosource::TaxonomySearchService.call({ 'member_ids' => po_doc.id})&.first
            this_media_extras['po_taxonomy'] = taxonomy.title&.first if taxonomy.present? && taxonomy.title.present?
          elsif po_doc.hydra_model == CulturalHeritageObject
            @po_type = "cho"
          end
        end
        this_media_extras
      end
    end

    def prepare_docs_and_filters_for_po(obj_type)
      case obj_type
      when 'bso'
        @bso_visibility_options = []
        @bso_source_options = []
        @paged_bso_member_docs = paginated_bso_item_list
        @bso_total_pages = bso_total_pages
        @bso_source_options = @bso_source_options.uniq
        @bso_extras = get_po_extras(@paged_bso_member_docs)
      when 'cho'
        @cho_visibility_options = []
        @paged_cho_member_docs = paginated_cho_item_list
        @cho_total_pages = cho_total_pages
        @cho_extras = get_po_extras(@paged_cho_member_docs)
      end
    end

    def get_po_extras(docs)
      docs.map do |doc|
        {
          'id' => doc.id,
          'origin' => po_origin(doc.id),
          'media_count' => Morphosource::PhysicalObjectParentSearchService.total_media_count(doc.id)
        }
      end
    end

    def po_origin(id)
      if @collection_organization_object_ids.present? && @collection_organization_object_ids.include?(id)
        'Org.'
      else
        'Team'
      end
    end

    def visibility_label(value)
      case value
      when 'open'
        display_value = "Public"
      when 'authenticated'
        display_value = "Duke University"
      when 'restricted'
        display_value = "Private"
      else
        display_value = value
      end
      display_value
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

    def organization_from_bso(bso)
      organization = Organization.where('member_ids_ssim' => bso.id).first
      organization
    end

  end
end
