# Added to allow for the My controller to show only things I have edit access to
class Morphosource::My::MsCollectionsSearchBuilder < ::SearchBuilder
  include Hyrax::My::SearchBuilderBehavior
  include Hyrax::FilterByType

  self.default_processor_chain += [:show_all_collections]

  # adds a filter to the solr_parameters that filters the collections and admin sets
  # the current user has deposited
  # @param [Hash] solr_parameters
  def show_only_collections_deposited_by_current_user(solr_parameters)
    clauses = [
      ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: current_user_key),
      ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::AdminSet.to_s, creator: current_user_key)
    ]
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += ["(#{clauses.join(' OR ')})"]
  end

  # todo: might need to figure out a way to search for collections that the current user has any 
  # access to (manager, editor, depositor, viewer, downloader)
  def show_all_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: 'Collection')]
#    solr_parameters[:fq] += ["collection_type_gid_ssim:\"gid://morpho-source-sf/hyrax-collectiontype/2\""]
  end

  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    [::AdminSet, ::Collection]
  end
end
