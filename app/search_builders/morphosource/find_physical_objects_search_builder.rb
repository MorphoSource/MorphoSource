class Morphosource::FindPhysicalObjectsSearchBuilder < Morphosource::FindWorksSearchBuilder
  include SolrHelper

  self.default_processor_chain -= [:filter_on_title]
	self.default_processor_chain += [:filter_on_po_fields]

  def filter_on_po_fields(solr_parameters)
    query_terms = query_or(@q)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [
      search_terms.map { |x| "(#{x}:#{query_terms})" }.join(' OR ') 
    ]
  end

  def query_or(q)
    "(#{@q.split(' ').map { |x| prepare_value(x) }.join(' OR ')} OR #{prepare_value(@q)})"
  end

  def search_terms
    [
      :id,
      :institution_code_tesim,
      :collection_code_tesim,
      :catalog_number_tesim,
      :identifier_tesim,
      :idigbio_uuid_tesim,
      :occurrence_id_tesim,
      :short_title_tesim
    ]
  end
end