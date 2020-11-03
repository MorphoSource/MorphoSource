class Morphosource::My::FindMediaSearchBuilder < Hyrax::My::FindWorksSearchBuilder
  self.default_processor_chain -= [:show_only_resources_deposited_by_current_user, :filter_on_title]
	self.default_processor_chain += [:filter_on_title_or_id]

  def filter_on_title_or_id(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [
      ::ActiveFedora::SolrQueryBuilder.construct_query(
        {
          title_tesim: @q,
          id: @q
        },
        join_with = ' OR '
      )
    ]
  end

  def models
    [Media]
  end
end