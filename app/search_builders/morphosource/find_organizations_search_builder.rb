class Morphosource::FindOrganizationsSearchBuilder < Morphosource::FindWorksSearchBuilder
  self.default_processor_chain -= [:filter_on_title]
	self.default_processor_chain += [:filter_on_org_fields]

  def filter_on_org_fields(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [
      ::ActiveFedora::SolrQueryBuilder.construct_query(
        {
          title_tesim: @q,
          institution_name_tesim: @q,
          institution_code_tesim: @q,
          collection_code_tesim: @q
        },
        join_with = ' OR '
      )
    ]
  end

  def models
    [Organization, OrganizationCollection]
  end
end