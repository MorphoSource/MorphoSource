module MorphosourceHelper

  include ActionView::Helpers::UrlHelper
  include Hyrax::Renderers

  class RemoteFileInfo
    attr_accessor :message, :http_code, :file_ext, :status, :content_length, :e_tag

    def initialize(url)
      @message = ""
      @status = ""
      @http_code = ""
      @file_ext = ""
      @content_length = ""
      @e_tag = ""
      begin
        head = RestClient::Request.execute(method: :head, url: url, timeout: 15)
        @http_code = head.code
        @file_ext = file_extension_from_content_type(head.headers[:content_type])
        @status = "success"
      rescue RestClient::Exception => e
        @message = "#{e.message}"
        @http_code = e.http_code
      rescue Exception => e
        @message = "#{e.message}"
        @http_code = ""
      end
      if @status == "success"
        @content_length = head.headers[:content_length]
        @e_tag = head.headers[:etag]&.gsub(/^\"|\"?$/, '')
      else
        @status = @http_code.present? ? "error" : "fail"
      end
    end

    def file_extension_from_content_type(content_type)
      return "" unless content_type.present?
      case content_type
      when "application/zip"
        ".zip"
      when "image/gif"
        ".gif"
      when /^image\/jpe?g$/
        ".jpg"
      when "image/png"
        ".png"
      when "image/bmp"
        ".bmp"
      when "image/tiff"
        ".tif"
      when "application/dicom"
        ".dcm"
      when "image/jpeg2000"
        ".jp2"
      when "image/svg+xml"
        ".svg"
      when "application/ply"
        ".ply"
      when "application/stl"
        ".stl"
      when "text/prs.wavefront-obj"
        ".obj"
      when "model/gltf+json"
        ".gltf"
      when "model/vrml"
        ".wrl"
      when "model/x3d+xml"
        ".x3d"
      when /^video\/mpe?g$/
        ".mpg"
      when "video/mp4"
        ".mp4"
      when "video/quicktime"
        ".mov"
      when "video/avi"
        ".avi"
      when "video/x-m4v"
        ".m4v"
      when "video/x-ms-wmv"
        ".wmv"
      when "application/x-tar"
        ".tar"
      else
        @message = "Unknown content_type #{content_type}"
        Rails.logger.debug("in file_extension_from_header: Unknown content_type #{content_type}")
        ""
      end
    end

  end

  def solr_doc_find(id)
    begin
      return SolrDocument.find(id)
    rescue
      return nil
    end
  end

  def sitewide_banner?
    ActiveModel::Type::Boolean.new.cast(Morphosource::Forms::Admin::Banner.new.sitewide_banner)
  end

  def sitewide_banner_text
    Morphosource::Forms::Admin::Banner.new.sitewide_banner_text.body.to_html
  end

  def current_controller
    current_uri = request.env['PATH_INFO']
    # to-do: might need to catch exception here for route not found
    path = Rails.application.routes.recognize_path(current_uri)
    controller = path[:controller]
  end

  def current_controller?(names)
    names.include?(current_controller)
  end

  def request_params
    request.params
  end

  def truncate_value(value, length=20)
    return "" if value.nil?
    value.truncate(length)
  end

  def ark_link(id)
    if id.present?
      return link_to(id, "//n2t.net/#{id}", target: :blank)
    else
      return "Not assigned"
    end
  end

  def device_selector
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    hits = devices
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def devices
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    qry = "#{ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)}:Device"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def device_organization
    return unless organization_id = @presenter&.device&.to_h&.dig("device_organization_id_ssim")&.first

    SolrDocument.where('id' =>  organization_id)&.first
  end

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def has_custom_thumbnail?(presenter)
    if presenter.nil? || presenter.thumbnail_id.nil?
      return false
    else
      custom_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(presenter.id,'thumbnail')
      has_custom_thumbnail = File.exist?(custom_thumbnail_path)
      return has_custom_thumbnail
    end
  end

  def generated_thumbnail(presenter)
    return '' unless presenter.representative_presenter.present?
    render_thumbnail_tag(presenter.representative_presenter, {}, {suppress_link:true})
  end

  def render_default_thumbnail
    image_tag(asset_path("work_gray.png"))
  end

  def find_works_autocomplete_url(curation_concern, relation)
    valid_concerns = curation_concern.send("valid_#{relation}_concerns").map(&:to_s)
    type_params = valid_concerns.sort.map { |type| "type[]=#{type}" }
    # add id in the url if missing since id is expected by find_works
    if type_params.find { |e| /^id=/ =~ e }.nil?
      type_params << "id=NA"
    end
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?' + type_params.join('&')
  end

  def find_parent_media_to_add_autocomplete_url(current_media_id)
    Rails.application.routes.url_helpers.qa_path + '/search/find_parent_media_to_add?type[]=Media&current_media_id=' + current_media_id + '&id=NA&q='
  end

  def organization_selector
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    hits = organizations
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  # choose path based on whether organization is a work or collection
  def organization_path(id)
    if Organization.exists?(id)
      main_app.show_organization_path(id)
    else
      main_app.organization_path(id)
    end
  end

  def organizations
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    qry = "#{ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)}:Organization"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def ms_work_form_tabs(work)
    if files_required?(work)
      %w[metadata files relationships]
    else
      %w[metadata relationships]
    end
  end

  # returns a string containing the human-readable names of the valid relation (child/parent) types for the provided
  # curation concern with a comma and space between each class name
  def valid_work_types_list(curation_concern, relation)
    valid_types = curation_concern.send("valid_#{relation}_concerns").map(&:human_readable_type)
    valid_types.sort.join(', ')
  end

  def media_selector
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    hits = media
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def media
    sortable_title_field = ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)
    qry = "#{ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)}:Media"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def find_media_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_media?type[]=Media&id=NA'
  end

  def find_organization_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_organizations?type[]=Organization&id=NA&q='
  end

  def find_organizations_for_device_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?type[]=Organization&type[]=OrganizationCollection&id=NA'
  end

  # Finds organizations with organization type that includes scanning facility
  def find_device_organization_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_device_organizations?type[]=Organization&id=NA&q='
  end

  # Finds organizations with organization type that includes object collection
  def find_object_organization_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_object_organizations?type[]=Organization&id=NA&q='
  end

  def find_organization_with_devices_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_organizations_with_devices?type[]=Organization&id=NA&q='
  end

  def find_taxonomy_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_taxonomies?type[]=Taxonomy&id=NA&q='
  end

  def find_taxonomy_submission_autocomplete_url
    '/submissions/search_taxonomy_ajax?type[]=Taxonomy&id=NA&q='
  end

  def find_taxonomy_submission_autocomplete_url_bso_edit
    '/submissions/search_taxonomy_ajax?type[]=Taxonomy&id=NA&q='
  end

  def find_device_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_devices?type[]=Device&id=NA&q='
  end

  def find_biological_specimen_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_biological_specimens?type[]=BiologicalSpecimen&id=NA&q='
  end

  def find_cultural_heritage_object_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_cultural_heritage_objects?type[]=CulturalHeritageObject&id=NA&q='
  end

  def find_collection_to_add_media_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_collections_to_add_media?id=NA'
  end

  def collapse_expand_panel(block)
    content_tag :div, :class => "row collapse-button" do
      content_tag :div, :class => "panel-title" do
        content_tag :a, :data => {:toggle => "collapse"}, :href => %(##{block}), :class => "btn #{block}", :aria => {:label => "collapse/expand"} do
          concat content_tag(:span, "", class: "glyphicon glyphicon-triangle-bottom")
          concat "Show more"
          concat content_tag(:span, "", class: "glyphicon glyphicon-triangle-bottom")
        end
      end
    end
  end

  def collapse_expand_panel_simple(label: "Show more", div_class: "", glyphicon_class: "glyphicon-triangle-bottom")
    content_tag :div, class: "collapse-button #{div_class}" do
      content_tag :a, class: "collapse-a", data: { toggle: "collapse", target: ".collapse-simple" }, aria: { label: "collapse/expand" } do
        concat "#{label} "
        concat content_tag(:span, "", class: "glyphicon #{glyphicon_class}")
      end
    end
  end

  def collapse_accordion_panel(block, data_parent, label, value, is_collapsed)
    if is_collapsed == true
      icon = "glyphicon-triangle-bottom"
    else
      icon = "glyphicon-triangle-top"
    end
    content_tag :a, :data => {:toggle => "collapse", :parent => %(##{data_parent})}, :href => %(##{block}), :aria => {:label => "collapse/expand"} do
      content_tag :div, :class => "row" do
        concat content_tag(:div, label, class: "col-xs-6 showcase-label")
        concat content_tag(:div, value, class: "col-xs-5 showcase-value")
        concat content_tag(:span, "", class: "col-xs-1 glyphicon #{icon} #{block}")
      end
    end
  end

  def render_hint_tag(text)
    content_tag :i, class: ["material-icons", "tooltip-icon"] do
      content_tag :p, class: ["hint", "hide"] do
        text
      end
    end
  end

  def render_publication_status_badge(document)
    return if document["fileset_accessibility_ssim"].nil?
    publication_status = document[ "fileset_accessibility_ssim"].first
    return publication_badge(publication_status)
  end

  def render_view_link_publication_status_badge(document)
    publication_status = document[ "fileset_accessibility_ssim"].first
    badge = publication_badge(publication_status)

    link_to(badge, polymorphic_path([main_app, document]), id:"permission_#{document.id}", class: 'visibility-link')
  end

  def publication_badge(value)
    Morphosource::PublicationBadge.new(value).render
  end

  def permission_badge_by_value(value)
    Hyrax::PermissionBadge.new(value).render
  end

  def permission_badge_from_media_document(solr_document)
    Morphosource::PublicationBadge.new(solr_document.publication_status).render
  end

  def organization_institution(id)
      # get the device organization title and institution name for a device
      organization_institution = ''
      organizations = Organization.where('member_ids_ssim' => id)
      if organizations.present?
        organization = organizations.first
        organization_institution = organization.title.first
        organization_institution += ' (' + organization.institution_name.first + ')' if organization.institution_name.present?
      end
      organization_institution
  end

  def extra(extras, id)
    item = {}
    extras.each do |h|
      if h['id'] == id
        item.merge!(h)
      end
    end
    item.delete('id')
    item
  end

  # todo; replace this method with extra
  def render_extra(extras, id, variable)
    begin
      extras.find { |h| h['id'] == id }[variable]
    rescue Exception => e
      return 'unknown'
    end
  end

  def organization_devices(id)
    # get device id, make, and model for all devices associated with organization id
    SolrDocument.where('has_model_ssim' => 'Device', 'device_organization_id_ssim' => id).map do |d|
      {
        'id': d.id,
        'title': d.title,
        'creator': d.creator,
        'modality': d.modality,
        'description': d.description
      }
    end
  end

  def render_source_of_record(bso)
    renderer = Hyrax::Renderers::ShowcaseIdigbioLinkAttributeRenderer.new(nil,nil)
    renderer.generated_link_from_bso(bso)
  end

  def source_of_record(idigbio_uuid, idigbio_recordset_id)
    markup = ''
    return markup unless idigbio_uuid.present?
    # For now we just handle idigbio.  Later will probably handle uuid and recordset links, and other providers
    #
    # if label.include? 'UUID'
    #   url = 'https://www.idigbio.org/portal/records/'
    # elsif label.include? 'recordset ID'
    #   url = 'https://www.idigbio.org/portal/recordsets/'
    # else
    #   url = 'https://www.idigbio.org'
    # end
    value = ''
    url = 'https://www.idigbio.org/'
    #link = link_to(value, "#{url}#{value}")
    #markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
    #markup << link
    #markup
    url
  end

  def display_source(bso)
    if bso.idigbio_uuid.present?
      return "iDigbio"
    else
      return 'User'
    end
  end

  def display_date(value)
    # first try to parse and format the date generated from datepicker (YYYY-MM-DD)
    # for other format, e.g. "04/26/2019", it will throw invalid date exception
    # in thac case, use DateTime.strptime instead
    begin
      Date.parse(value).to_formatted_s(:long)
    rescue StandardError => e
      if e.message == 'invalid date'

        begin
          # attempt to parse the date
          parsed_date = Date.strptime(value, "%m/%d/%Y")
          if parsed_date.present?
            parsed_date.to_formatted_s(:long)
          else
            value # just return the string as it is
          end
        rescue StandardError => e
          value # just return the string as it is
        end

      elsif e.message.include?("no implicit conversion of Date")
        # since the value passed in is already a Date class, just format it
        value.to_formatted_s(:long)
      else
        # if landed here. check e.message for the exception message
        Rails.logger.info("Error in display_date: #{e.message} ")
        '(Error)'
      end
    end
  end

  def collection_form_url(form)
    form.persisted? ? url_for(action: 'update') : url_for(action: 'create')
  end

  # used when editing team projects, populates select list of projects that can be added to the team
  def eligible_child_projects
    if current_user.admin?
      Morphosource::SolrService.new.get_docs('human_readable_type_sim:Project NOT member_of_collection_ids_ssim:*')
    else
      Morphosource::Collections::NestedCollectionQueryService.available_project_collections(parent: @collection, scope: controller)
    end
  end

  def grouped_access_list(f)
    manager = f.object.user_with_ownership
    individual_list = []
    group_list = {}
    # User and group based access
    f.fields_for :permissions do |permission_fields|
      role_name = permission_fields.object.agent_name
      user_list = user_list_by_role(role_name)
      # skip the public, registered, and depositor perms as they are displayed first at the top
      next if ( ['admin', 'public', 'registered', manager].include? role_name.downcase )

      if user_list.empty?
        individual_list << permission_fields if !role_name.include?('_')
      else
        group_id, role_category = role_name.split('_', 2)
        access = permission_fields.object.access # read or edit
        next if role_category == 'depositors' # depositors have no collection-level access to works

        group_list[group_id] ||= {
          access_override: (access == "read") ? access : nil,
          users: {}
        }
        group_list[group_id][:users][role_category] = user_list.join(', ')
      end
    end
    # Organization collection based access
    # object organization
    if (org = f&.object&.model&.organizations&.first).present? && (org.class == OrganizationCollection)
      # If the org does not manage the media, all org members only have view access
      group_list[org.id] ||= {
        access_override: manager != org.id ?  'read' : nil,
        users: {}
      }

      org.user_groups.each do |role, hash|
        role_category = role.name.split('_', 2)[1]
        next if role.users.count == 0 || role_category == 'depositors'
        group_list[org.id][:users][role_category] = role.users.map { |u| "#{u.name_or_email} (#{role_category.singularize})"}.join(', ')
      end
    end
    # device organization
    if (org = device_organization).present? && (org['has_model_ssim'] == ['OrganizationCollection'])
      # If the org does not manage the media, all org members only have view access
      group_list[org.id] ||= {
        access_override: manager != org.id ? 'read' : nil,
        users: {}
      }
      group_names = ["#{org.id}_managers", "#{org.id}_editors", "#{org.id}_downloaders", "#{org.id}_viewers"]
      user_groups = group_names.each_with_object([]) { |role, arr| arr << Role.find_by(name: role) }.compact
      user_groups.each do |role, hash|
        role_category = role.name.split('_', 2)[1]
        next if role.users.count == 0
        group_list[org.id][:users][role_category] = role.users.map { |u| "#{u.name_or_email} (#{role_category.singularize})"}.join(', ')
      end
    end
    return individual_list, group_list
  end

  def group_title_link(id)
    collection = Collection.find(id)
    if collection.present?
      if collection.project?
        source = link_to "Project #{collection.id}: #{collection.title&.first}", main_app.project_path(collection)
      elsif collection.team?
        org_name = collection.organization_name.present? ? " (#{collection.organization_name.first})" : ""
        source = link_to "Team #{collection.id}: #{collection.title&.first}#{org_name}", main_app.team_path(collection)
      elsif collection.organization_collection?
        source = link_to "Organization #{collection.id}: #{collection.name}", main_app.organization_path(collection)
      else
        source = "(unknown)"
      end
    end
    return source.html_safe
  end

  def group_user_access_desc(role_category, access_override = nil)
    if access_override
      case access_override
      when 'edit'
        'Edit access'
      when 'read'
        'View access'
      else
        'Unknown access'
      end
    else
      case role_category
      when 'managers'
        'Edit access'
      when 'editors'
        'Edit access'
      when 'downloaders'
        'Download access'
      when 'viewers'
        'View access'
      else
        'Unknown access'
      end
    end
  end

  def user_list_by_role(access)
    list = []
    Role.find_by(name: access)&.users&.each do |u|
      user_display = u.name_or_email
      if access.split('_').length == 2
        user_display += " (" + access.split('_')[1].singularize + ")"
      end
      list << user_display
    end
    return list
  end

  def user_display(user_key)
    user = ::User.find_by_user_key(user_key)
    return user_key if user.nil?
    user.display_name.present? ? user.display_name : user.email
  end

  def sftp_share_status(path)
    return "" unless path.present?
    icon = '<i class="glyphicon glyphicon-alert tooltip-icon text-alert"><p class="hint hide">Not connected</p></i>'
    if sftp_share_connected? path
      icon = '<i class="glyphicon glyphicon-ok-sign tooltip-icon text-success" data-original-title="" title=""><p class="hint hide">Connected</p></i>'
    end
    return icon.html_safe
  end

  def sftp_share_connected?(path)
    return false unless path.present?
    return (Dir.exist?(Hyrax.config.sftp_share_root + path) or Dir.exist?(path))
  end
end

class Array

  def ignore_case_include?(value)
    return false unless self.present? && value.present?
    self.each do |e|
      if e.downcase == value.downcase
        return true
        break
      end
    end
    return false
  end

  def ignore_case_included_value(value)
    return nil unless self.present? && value.present?
    self.each do |e|
      if e.downcase == value.downcase
        return e
        break
      end
    end
    return nil
  end

  def to_wrapped_html(tag, classes="")
    if classes.present?
      self.map { |c| "<#{tag} class='#{classes}'>#{c}</#{tag}>" }.join.html_safe
    else
      self.map { |c| "<#{tag}>#{c}</#{tag}>" }.join.html_safe
    end
  end

end
