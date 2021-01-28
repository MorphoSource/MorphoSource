# Added to allow for the My controller to show only things I have edit access to
class Morphosource::My::MsCollectionsSearchBuilder < ::SearchBuilder
  #include Hyrax::My::SearchBuilderBehavior
  #include Hyrax::FilterByType

  #self.default_processor_chain += [:show_all_collections]

  def initialize(scope:)
    super(scope)
  end

  #def show_all_collections(solr_parameters)
  #  solr_parameters[:fq] ||= []
  #  solr_parameters[:fq] += [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: 'Collection')]
  #  solr_parameters[:fq]
  #end


  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    #[::AdminSet, ::Collection]
    [::Collection]
  end

end
