module Hyrax
  class OrganizationMemberSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType
    attr_reader :search_includes_models

    def initialize(scope:,
                   search_includes_models: :works)
      @search_includes_models = search_includes_models
      super(scope)
    end

    # This overrides the models in FilterByType
    def models
      work_classes
    end
  end
end
