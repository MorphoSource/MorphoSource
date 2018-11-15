module MorphosourceHelper

  def files_required?(work)
    if Hyrax.config.work_requires_files?
      true
    else
      work.class.work_requires_files?
    end
  end

  def institution_object_selector(institution_id)
    inst_doc = SolrDocument.find(institution_id)
    inst_member_ids = inst_doc[Solrizer.solr_name('member_ids', :symbol)]
    inst_member_docs = inst_member_ids.map { |id| SolrDocument.find(id) }
    inst_object_docs = inst_member_docs.select do |doc|
      [ 'BiologicalSpecimen', 'CulturalHeritageObject' ].include?(doc[Solrizer.solr_name('has_model', :symbol)].first)
    end
    inst_object_docs.map { |doc| [ doc.sortable_title, doc.id ] }.sort_by { |e| e[0] }
  end

  def institution_selector
    sortable_title_field = Solrizer.solr_name('title', :stored_sortable)
    qry = "#{Solrizer.solr_name('has_model', :symbol)}:Institution"
    hits = ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{sortable_title_field} ASC")
    hits.map { |hit| [ hit[sortable_title_field], hit.id ] }
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
