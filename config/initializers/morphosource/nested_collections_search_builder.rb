Hyrax::Dashboard::NestedCollectionsSearchBuilder.class_eval do
  # This is the original Hyrax method
  def show_only_other_collections_of_the_same_collection_type(solr_parameters)
    # override to allow projects to be nested within teams and prevent teams and projects nesting with their own type.
    show_only_valid_collection_types(solr_parameters)
  end

  # New method
  # When adding a project as a child, return teams
  # When adding a team as a parent, return projects
  # If collection is not a team or project, return only collections of same type
  def show_only_valid_collection_types(solr_parameters)
    solr_parameters[:fq] ||= []
    # return teams
    if nesting_project_as_child?
      gid = Hyrax::CollectionType.find_by(title: "Team").gid
    # return projects
    elsif nesting_team_as_parent?
      gid = Hyrax::CollectionType.find_by(title: "Project").gid
    # return same collection type
    else
      gid = @collection.collection_type_gid
    end
    solr_parameters[:fq] += [
      "-" + ActiveFedora::SolrQueryBuilder.construct_query_for_ids(limit_ids), ActiveFedora::SolrQueryBuilder.construct_query(Collection.collection_type_gid_document_field_name => gid)]
    solr_parameters[:fq] += limit_clause if limit_clause # add limits to prevent illegal nesting arrangements
  end

  private

    def nesting_project_as_child?
      @collection.project? && @nest_direction == :as_parent
    end

    def nesting_team_as_parent?
      @collection.team? && @nest_direction == :as_child
    end

end
