Hyrax::Collections::NestedCollectionQueryService.module_eval do

  # Include both projects and teams in results if adding a project to another collection as a child or a team to another collection as a parent
  def self.parent_and_child_can_nest?(parent:, child:, scope:)
    return false if parent == child # Short-circuit
    # Disable line below to allow projects to be nested within teams
    # return false unless parent.collection_type_gid == child.collection_type_gid
    if parent.collection_type_gid != child.collection_type_gid
      return false unless parent.team? && child.project?
    end
    return false if available_parent_collections(child: child, scope: scope, limit_to_id: parent.id).none?
    return false if available_child_collections(parent: parent, scope: scope, limit_to_id: child.id).none?
    true
  end

end
