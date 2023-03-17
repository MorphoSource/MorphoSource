# helper methods for teams and project collection show and edit pages
module Morphosource
  module CollectionHelper

    def locale
      locale = params[:locale] ||= 'en'
      '?locale=' + locale
    end

    def active_tab?(tab)
      @tab == tab ? 'active' : ''
    end

    # show page main/media tab
    def collection_media_path(collection)
      main_app.send("#{collection_type_machine_id(collection)}_path", collection)
    end
    alias media_tab_url collection_media_path


    # show page main/specimens tab
    def specimens_tab_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_specimens_path", collection)
    end

    # show page main/chos tab
    def chos_tab_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_chos_path", collection)
    end

    # show page main/about tab
    def about_tab_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_about_path", collection)
    end

    # dashboard edit members tab
    def members_tab_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_members_path", collection)
    end

    def chos_export_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_chos_export_path", request.parameters.merge(id: collection.id, :format => :csv, :per_page => 1000000))
    end

    def specimens_export_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_specimens_export_path", request.parameters.merge(id: collection.id, :format => :csv, :per_page => 1000000))
    end

    def media_export_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_media_export_path", request.parameters.merge(id: collection.id, :format => :csv, :per_page => 1000000))
    end

    def media_downloads_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_media_downloads_path", id: collection.id, :format => :csv, :per_page => 1000000)
    end

    def media_download_counts_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_media_download_counts_path", request.parameters.merge(id: collection.id, :format => :csv, :per_page => 1000000))
    end

    def media_requests_csv_url(collection)
      main_app.send("#{collection_type_machine_id(collection)}_media_requests_path", id: collection.id, :format => :csv, :per_page => 1000000)
    end

    def collection_edit_path(collection)
      main_app.send("#{collection_type_machine_id(collection)}_edit_path", collection)
    end

    def update_collection_path(collection)
      main_app.send("update_#{collection_type_machine_id(collection)}_path", collection)
    end

    def my_collections_type_path(collection)
      main_app.send("my_#{collection_type_machine_id(collection)}s_path")
    end

    def page_is_team?
      path_info.include?("teams")
    end

    def page_is_organization?
      path_info.include?("organizations")
    end

    def page_is_project?
      path_info.include?("projects")
    end

    def page_is_media_list?
      path_info.include?("media_lists")
    end

    def page_is_sequential_section_list?
      path_info.include?("sequential_section_lists")
    end

    def collection_type
      if page_is_team?
        'team'
      elsif page_is_project?
        'project'
      elsif page_is_media_list?
        'media list'
      elsif page_is_sequential_section_list?
        'sequential section list'
      end
    end

    def collection_count_for(count)
      count.to_s + ' ' + @collection_list_type.pluralize(count)
    end

    def showpage_url(id, tab)
      if page_is_team?
        Rails.application.routes.url_helpers.team_path(id) + "\##{tab}"
      elsif page_is_organization?
        Rails.application.routes.url_helpers.show_organization_path(id) + "\##{tab}"
      elsif page_is_project?
        Rails.application.routes.url_helpers.project_path(id) + "\##{tab}"
      end
    end

    def ms_dashboard_my_collection_link
      if page_is_team?
        "/dashboard/my/teams"
      elsif page_is_project?
        "/dashboard/my/projects"
      else
        ""
      end
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

    def bso_tab_url_for_collections(id)
      url_params = request_params.
        map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/projects/specimens/#{id}?#{url_params}"
    end

    def cho_tab_url_for_collections(id)
      url_params = request_params.
        map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/projects/chos/#{id}?#{url_params}"
    end

    def dashboard_bso_tab_url(id)
      url_params = request_params.
        map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/dashboard/collections/specimens/#{id}?#{url_params}"
    end

    def dashboard_cho_tab_url(id)
      url_params = request_params.
        map { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" if !['utf8', 'controller', 'action', 'id'].include?(k) }.
        compact.
        join('&')
      "/dashboard/collections/chos/#{id}?#{url_params}"
    end

    def prepare_docs_and_filters_for_media(collection)
      @is_team = collection.respond_to?(:team?) ? collection.team? : false
      @visibility_options = []
      if @subcollection_docs.present?
        team_projects = @subcollection_docs.map{|tp| [tp.id, tp.title.first]}
      end
      #@team_project_options = @subcollection_docs.map(&:title).flatten unless @subcollection_docs.nil? # [] for projects
      @bso_source_options = []
      @cho_visibility_options = []

      @media_member_docs = @member_docs
      @media_member_count = @members_count
      @paged_media_member_docs = paginated_media_item_list
      @media_extras = get_media_extras(@paged_media_member_docs, team_projects, collection.organization&.id)
      @po_type = "bso" unless @po_type.present?
    end

    def get_media_extras(docs, team_projects, team_org_id)
      docs.map do |doc|
        this_media_extras = {
          'id' => doc.id
        }
        if @is_team
          media_collection_ids = doc.member_of_collection_ids
          if media_collection_ids.present?
            if media_collection_ids.include? collection.id
              this_media_extras['origin'] = 'Team'
            elsif team_projects.present?
              team_projects.each do |id, title|
                if media_collection_ids.include? id
                  this_media_extras['team_project_title'] = title
                  this_media_extras['origin'] = 'Team' # or Team project, specifically
                end
              end
            end
          end
          # check if media is from a linked organization:
          if doc.media_organization_id&.include? team_org_id
            if this_media_extras['origin'].present?
              this_media_extras['origin'] += ', Organization'
            else
              this_media_extras['origin'] = 'Organization'
            end
          end
        end # /is_team
        # get BSO and CHO
        po_doc = Morphosource::PhysicalObjectParentSearchService.call({ id: doc.id })&.first
        if po_doc.present?
          this_media_extras['po_title'] = po_doc.title&.first
          if po_doc.hydra_model == BiologicalSpecimen
            @po_type = "bso"
            taxonomy = Morphosource::TaxonomySearchService.call({ 'id' => po_doc.taxonomy_id&.first})&.first if po_doc.taxonomy_id.present?
            this_media_extras['po_taxonomy'] = taxonomy.title&.first if taxonomy.present? && taxonomy.title.present?
          elsif po_doc.hydra_model == CulturalHeritageObject
            @po_type ||= "cho"
          end
        end
        this_media_extras
      end
    end

    def prepare_docs_and_filters_for_po(collection)
      @bso_visibility_options = []
      @bso_source_options = []
      @cho_visibility_options = []

      @paged_bso_member_docs = paginated_bso_item_list
      @bso_total_pages = bso_total_pages
      @paged_cho_member_docs = paginated_cho_item_list
      @cho_total_pages = cho_total_pages

      @bso_source_options = @bso_source_options.uniq

      @bso_extras = get_po_extras(@paged_bso_member_docs)
      @cho_extras = get_po_extras(@paged_cho_member_docs)
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

    def render_constraints_filters(localized_params = params)
      return "".html_safe unless localized_params[:f]
      path = controller.search_state_class.new(localized_params, blacklight_config, controller)
      content = []
      localized_params[:f].each_pair do |facet,values|
        content << render_filter_element(facet, values, path)
      end

      safe_join(content.flatten, "\n")
    end

    def morphosource_collection_controller?
      collection_controllers = [ Morphosource::Collections::TeamsController,
                                 Morphosource::Collections::ProjectsController,
                                 Morphosource::Collections::MediaListsController,
                                 Morphosource::Collections::MediaLists::SequentialSectionListsController,
                                 Morphosource::Collections::BiologicalSpecimensController,
                                 Morphosource::Collections::CulturalHeritageObjectsController]

      collection_controllers.include? controller.class
    end

    def first_media_is_specimen?(doc)
      doc["media_physical_object_type_ssim"] == ["Biological Specimen"]
    end

    def morphosource_physical_objects_controller?
      collection_controllers = [ Morphosource::Collections::BiologicalSpecimensController,
                                 Morphosource::Collections::CulturalHeritageObjectsController]

      collection_controllers.include? controller.class
    end

    def collection_type_machine_id(collection)
      collection = Collection.find(collection) if collection.is_a? String
      collection.collection_type.machine_id
    end

    def order_media_path(collection)
      collection_type = collection.collection_type.machine_id
      main_app.send("#{collection_type}_order_media_path", collection)
    end

    def order_media_sort(sort)
      sort.nil? ? "id,asc" : sort.split.join(',')
    end

    def order_media_page(page)
      page.nil? ? "1" : page
    end

    def order_media_per_page(count)
      count.nil? ? @blacklight_config.default_solr_params[:rows].to_s : count
    end

  end
end
