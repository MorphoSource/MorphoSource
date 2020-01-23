Hyrax::Collections::NestedCollectionQueryService.module_eval do

  # Override to allow teams to have child projects
  def self.parent_and_child_can_nest?(parent:, child:, scope:)
    return false if parent == child # Short-circuit
    if parent.collection_type_gid != child.collection_type_gid
      # Teams are able to have child projects
      return false unless parent.team? && child.project?
      # Projects can have only one parent
      return false if child.parent?
    else
      return false if parent.team? || parent.project?
    end
    return false if available_parent_collections(child: child, scope: scope, limit_to_id: parent.id).none?
    return false if available_child_collections(parent: parent, scope: scope, limit_to_id: child.id).none?
    true
  end

  # @api public
  #
  # What possible collections can be nested within the given parent collection?
  #
  # @param parent [Collection]
  # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
  # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
  # @return [Array<SolrDocument>]
  def self.available_child_collections(parent:, scope:, limit_to_id: nil)
    return [] unless parent.try(:nestable?)
    return [] unless scope.can?(:deposit, parent)
    # projects can't have child collections
    return [] if parent.project?
    results = query_solr(collection: parent, access: :read, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_child).documents
    # if parent is a team, return only projects without parents
    results.select!{ |r| r["nesting_collection__parent_ids_ssim"].nil? } if parent.team?
    results
  end

  # @api public
  #
  # What possible collections can the given child be nested within?
  #
  # @param child [Collection]
  # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
  # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
  # @return [Array<SolrDocument>]
  def self.available_parent_collections(child:, scope:, limit_to_id: nil)
    return [] unless child.try(:nestable?)
    return [] unless scope.can?(:read, child)
    # teams can't have parent collections
    return [] if child.team?
    # projects can have only one parent
    return [] if child.project? && child.parent?
    query_solr(collection: child, access: :deposit, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_parent).documents
  end
end
