module MorphosourceHelper
  
  include ActionView::Helpers::UrlHelper
  include MediaFinderHelper
  include Hyrax::Renderers

  def current_controller
    current_uri = request.env['PATH_INFO']
    # to-do: might need to catch exception here for route not found
    path = Rails.application.routes.recognize_path(current_uri)
    controller = path[:controller]
  end

  def current_controller?(names)
    names.include?(current_controller)
  end

  def collection_view_link(id, view, anchor=nil)
    current_uri = request.env['PATH_INFO']
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
    link = link + "#" + anchor if anchor.present?
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

  def truncate_value(value, length=20)
    return "" if value.nil?
    value.truncate(length)
  end

  def device_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = devices
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def devices
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Device"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def has_custom_thumbnail?(work)
    if work.nil? || work.thumbnail_id.nil?
      return false
    else
      original_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(work.thumbnail_id,'original_thumbnail')
      has_custom_thumbnail = File.exist?(original_thumbnail_path)
      return has_custom_thumbnail
    end
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
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = organizations
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def organizations
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Organization"
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
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = media
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def media
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Media"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def find_media_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?type[]=Media&id=NA&q='
  end

  def find_organization_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_organizations?type[]=Organization&id=NA&q='
  end

  def find_taxonomy_autocomplete_url
    Rails.application.routes.url_helpers.qa_path + '/search/find_taxonomies?type[]=Taxonomy&id=NA&q='
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

  def collapse_expand_panel(block, state:"COLLAPSE", expand_button_text:"Show more", collapse_button_text:"Show less")
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

  def is_number_with_decimal? string
    true if Float(string).to_f % 1 != 0 rescue false
  end

  def publication_badge(value)
    Morphosource::PublicationBadge.new(value).render
  end

  def render_publication_status_badge(document)
    media = Media.find(document.id)

    path = edit_polymorphic_path([main_app, document], anchor: 'share')

    link_to(
      publication_badge(media.publication_status),
      path,
      id: "permission_#{document.id}",
      class: 'visibility-link'
    )
  end

  def permission_badge_by_value(value)
    Hyrax::PermissionBadge.new(value).render
  end

  def generated_media_title(part, media_type, ie_modality)
    # id will be added by add_id_to_title in Media model
    parts = part.presence || ['Element unspecified']
    media_type = media_type&.first.presence || ''
    modality_abbrevs = ie_modality.map { |m| modality_abbrev(m) }
    title = parts.sort.join(', ').titleize + (media_type.presence ? ' [' + media_type.to_s + ']' : '') + (modality_abbrevs.presence ? ' [' + modality_abbrevs.join('/')+ ']' : ' [Etc]')
    title
  end

  def modality_abbrev(m)
    case m
    when 'MicroNanoXRayComputedTomography'
      'μCT'
    when 'MedicalXRayComputedTomography'
      'CT'
    when 'MagneticResonanceImaging'
      'MRI'
    when 'PositronEmissionTomography'
      'PET'
    when 'SynchrotronImaging'
      'Synchro'
    when 'NeutrinoImaging'
      'Neutrino'
    when 'Photogrammetry'
      'Photogram'
    when 'StructuredLight'
      'StrLight'
    when 'LaserScan'
      'Laser'
    when 'ConfocalImageStacking'
      'Confocal'
    when 'Infrared'
      'Infrared'
    when 'ReflectanceTransformationImaging'
      'RTI'
    when 'Photography'
      'Photo'
    when 'ScanningElectronMicroscopy'
      'SEM'
    else
      'Etc' 
    end
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

end
