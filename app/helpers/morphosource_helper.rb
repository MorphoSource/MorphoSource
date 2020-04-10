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

  def collection_type_from_path
    current_uri = request.env['PATH_INFO']
    if current_uri.include?("teams")
      "teams"
    elsif current_uri.include?("projects")
      "projects"
    end      
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

  def render_extra(extras, id, variable)
    extras.find { |h| h['id'] == id }[variable]
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

      else
        # if landed here. check e.message for the exception message
        Rails.logger.info("Error in display_date: #{e.message} ")
        '(Error)'
      end
    end

  end

end
