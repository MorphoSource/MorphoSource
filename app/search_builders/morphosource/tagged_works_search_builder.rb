module Morphosource

  class TaggedWorksSearchBuilder < Hyrax::SearchBuilder

    self.default_processor_chain += [
    :add_access_controls_to_solr_params,
    :show_only_works_with_keyword
    ]

    def only_works?
      true
    end

    # This overrides the models in FilterByType
    def models
      [::Media]
    end

    def show_only_works_with_keyword(solr_parameters)
      keyword = @scope.params[:tag]
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] += [
        "keyword_tesim:(#{keyword})"
      ]
    end

  end
end
