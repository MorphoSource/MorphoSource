# Added to allow for the My controller to show only things I have edit access to
class Morphosource::My::MediaListsSearchBuilder < ::SearchBuilder
  include Hyrax::My::SearchBuilderBehavior
  include Hyrax::FilterByType


  def discovery_permissions
     @discovery_permissions ||= ["edit"]
  end

  # This overrides the models in FilterByType
  # @return [Array<Class>] a list of classes to include
  def models
    [::MediaList]
  end
end
