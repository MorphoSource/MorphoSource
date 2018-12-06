module MorphosourceHelper

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def physical_object_selector(institution_id=nil)
    if institution_id.present?
      institution_objects(institution_id).map { |doc| [ doc.sortable_title, doc.id ] }.sort_by { |e| e[0] }
    else
      sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
      hits = physical_objects
      hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
    end
  end

  def institution_objects(institution_id)
    inst_doc = SolrDocument.find(institution_id)
    if inst_member_ids = inst_doc[Solrizer.solr_name('member_ids', :symbol)]
      inst_member_docs = inst_member_ids.map { |id| SolrDocument.find(id) }
      inst_member_docs.select do |doc|
        [ 'BiologicalSpecimen', 'CulturalHeritageObject' ].include?(doc[Solrizer.solr_name('has_model', :symbol)].first)
      end
      inst_member_docs.sort_by { |doc| doc.sortable_title }
    else
      []
    end
  end

  def institution_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    hits = institutions
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
  end

  def institutions
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Institution"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def object_imaging_event_selector(object_id)
    if obj_imaging_event_docs = object_imaging_events(object_id)
      obj_imaging_event_docs.map { |doc| [ doc.sortable_title, doc.id ] }.sort_by { |e| e[0] }
    else
      []
    end
  end

  def object_imaging_events(object_id)
    obj_doc = SolrDocument.find(object_id)
    if obj_member_ids = obj_doc[Solrizer.solr_name('member_ids', :symbol)]
      obj_member_docs = obj_member_ids.map { |id| SolrDocument.find(id) }
      obj_member_docs.select { |doc| doc[Solrizer.solr_name('has_model', :symbol)].first == 'ImagingEvent' }
    else
      []
    end
  end

  def physical_objects
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    biospec_clause = "#{Solrizer.solr_name('has_model', :symbol)}:BiologicalSpecimen"
    cho_clause = "#{Solrizer.solr_name('has_model', :symbol)}:CulturalHeritageObject"
    qry = "#{biospec_clause} OR #{cho_clause}"
    ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
  end

  def find_works_autocomplete_url(curation_concern, relation)
    valid_concerns = curation_concern.send("valid_#{relation}_concerns").map(&:to_s)
    type_params = valid_concerns.sort.map { |type| "type[]=#{type}" }
    Rails.application.routes.url_helpers.qa_path + '/search/find_works?' + type_params.join('&')
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

end
