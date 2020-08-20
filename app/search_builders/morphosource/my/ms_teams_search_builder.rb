class Morphosource::My::MsTeamsSearchBuilder < ::SearchBuilder
  include Hyrax::My::SearchBuilderBehavior
  include Hyrax::FilterByType

  self.default_processor_chain += [:show_all_collections]

  def show_all_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: 'Collection')]
    solr_parameters[:fq] += ["collection_type_gid_ssim:\"gid://morpho-source-sf/hyrax-collectiontype/1\""]
  end

  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    [::AdminSet, ::Collection]
  end
end
