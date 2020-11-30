module SolrHelper
  # Solr utility methods for services that use solr

  def solr_service
    Morphosource::SolrService
  end

  def solrize(name, type)
    Solrizer.solr_name(name, type)
  end

  def desolrize(name)
    name[0...name.rindex('_')]
  end

  def assemble_or_query(field, values)
    return "" if !field.present? || !values.present?
    field + ':(' + values.join(' OR ').upcase + ')'
  end

  def assemble_query
    query_clauses = [ model_clause ] + param_clauses
    query_clauses.join(' AND ')
  end

  def param_clauses
    clauses = []
    params.each do |k,v|
      term_type = ( k == 'member_ids' ? :symbol : :stored_searchable )
      clauses << "#{Solrizer.solr_name(k, term_type)}:#{prepare_value(v)}"
    end
    clauses
  end

  def prepare_value(v)
    Morphosource::SolrService.prepare_value(v)
  end

  def assemble_po_id_or_collection_query(ids, collection_ids)
    return "" if !ids.present? || !collection_ids.present? 
    "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)}) OR (#{assemble_or_query(solrize('member_of_collection_ids', :symbol), Array(collection_ids))})"
  end

  def assemble_po_id_and_not_collection_query(ids, collection_id)
    return "" if !ids.present? || !collection_id.present? 
    "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)}) AND NOT (#{solrize('member_of_collection_ids', :symbol)}:#{collection_id})"
  end
end