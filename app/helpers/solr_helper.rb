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
      if k == 'id' || k == :id
        clauses << "id:#{prepare_value(v)}"
      else
        term_type = ( k == 'member_ids' ? :symbol : :stored_searchable )
        clauses << "#{Solrizer.solr_name(k, term_type)}:#{prepare_value(v)}"
      end
    end
    clauses
  end

  def prepare_value(v)
    Morphosource::SolrService.prepare_value(v)
  end

  def assemble_po_id_or_collection_query(ids, collection_ids)
    query = []
    query << "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)})" if ids.present?
    query << "(#{assemble_or_query(solrize('member_of_collection_ids', :symbol), Array(collection_ids))})" if collection_ids.present?
    return query.join(' OR ')
  end

  def assemble_po_id_and_not_collection_query(ids, collection_id)
    # todo: might need to check if ids should be handled separately (similar to assemble_po_id_or_collection_query) 
    return "" if !ids.present? || !collection_id.present? 
    "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)}) AND NOT (#{solrize('member_of_collection_ids', :symbol)}:#{collection_id})"
  end

  def assemble_po_id_including_collection_query(ids)
    return "" if !ids.present? 
    "(#{assemble_or_query(solrize('physical_object_id', :stored_searchable), ids)})"
  end
end