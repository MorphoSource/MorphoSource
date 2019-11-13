Hyrax::Dashboard::NestedCollectionsSearchBuilder.class_eval do

  # This is the original Hyrax method
  def show_only_other_collections_of_the_same_collection_type(solr_parameters)
    # override to allow projects to be nested within teams
    show_only_valid_collection_types(solr_parameters)
  end

  # New method
  # When adding a project as a child, return projects and teams
  # When adding a team as a parent, return projects and teams
  # Otherwise, return only collections of same type
  def show_only_valid_collection_types(solr_parameters)
    solr_parameters[:fq] ||= []
    project_gid = Hyrax::CollectionType.find_by(title: "Project").gid
    team_gid = Hyrax::CollectionType.find_by(title: "Team").gid
    if nesting_project_in_team?
      solr_parameters[:fq] += [
        "-" + ActiveFedora::SolrQueryBuilder.construct_query_for_ids(limit_ids), ActiveFedora::SolrQueryBuilder.construct_query([[Collection.collection_type_gid_document_field_name, project_gid],[Collection.collection_type_gid_document_field_name, team_gid]], ' OR ')]
    else
      solr_parameters[:fq] += [
        "-" + ActiveFedora::SolrQueryBuilder.construct_query_for_ids(limit_ids), ActiveFedora::SolrQueryBuilder.construct_query(Collection.collection_type_gid_document_field_name => @collection.collection_type_gid)]
    end
    solr_parameters[:fq] += limit_clause if limit_clause # add limits to prevent illegal nesting arrangements
  end

  private

    def nesting_project_in_team?
      return true if @collection.team? && @nest_direction == :as_child
      return true if @collection.project? && @nest_direction == :as_parent
      false
    end

end
