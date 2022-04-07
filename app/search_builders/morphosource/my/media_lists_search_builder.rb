# Added to allow for the My controller to show only things I have edit access to
class Morphosource::My::MediaListsSearchBuilder < ::SearchBuilder
  include Hyrax::My::SearchBuilderBehavior
  include Hyrax::FilterByType

  self.default_processor_chain += [:apply_list_ids_filter]

  def apply_list_ids_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << list_ids_filter
  end

  def list_ids_filter
    "(id:(#{list_ids.join(' OR ')}))"
  end

  def list_ids
    groups = @scope.current_ability.user_groups
    groups = groups.select{ |g| g.include? "creators" }
    groups.map{|group| group.split(/_/, 2).first}
  end

  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    [::MediaList]
  end
end
