module Morphosource

  class OrganizationsSearchBuilder < ::SearchBuilder
    include Hyrax::FilterByType

    self.default_processor_chain += [
      #:add_access_controls_to_solr_params,
      :show_only_organizations
    ]


    def only_works?
      true
    end

    # This overrides the models in FilterByType
    def models
      [::Organization]
    end

    def show_only_organizations(solr_parameters)
      solr_parameters[:fq] ||= ["#{solrize('visibility', :stored_sortable)}:open"]
      solr_parameters[:rows] = 999999
    end

  end
end
