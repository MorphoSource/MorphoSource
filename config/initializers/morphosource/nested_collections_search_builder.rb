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
    @collection_type = Hyrax::CollectionType.find_by_gid!(@collection.collection_type_gid)
    if nesting_project_as_child?
      gid = Hyrax::CollectionType.find_by(title: "Team").to_global_id.to_s
    # return projects
    elsif nesting_team_as_parent?
      gid = Hyrax::CollectionType.find_by(title: "Project").to_global_id.to_s
    # return same collection type
    else
      gid = @collection.collection_type_gid
    end

    solr_parameters[:fq] += [
      Hyrax::SolrQueryBuilderService.construct_query(Hyrax.config.collection_type_index_field => gid),
      "-{!graph from=id to=member_of_collection_ids_ssim#{' maxDepth=1' if @nest_direction == :as_parent}}id:#{@collection.id}",
      "-{!graph to=id from=member_of_collection_ids_ssim#{' maxDepth=1' if @nest_direction == :as_child}}id:#{@collection.id}"
    ]
  end

  private

  def nesting_project_as_child?
    ( @collection_type.machine_id == "project" ) && ( @nest_direction == :as_parent )
  end

  def nesting_team_as_parent?
    ( @collection_type.machine_id == "team" ) && ( @nest_direction == :as_child )
  end
end
