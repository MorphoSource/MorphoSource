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
      [::Organization, ::OrganizationCollection]
    end

    def show_only_organizations(solr_parameters)
      solr_parameters[:fq] ||= ["#{solrize('visibility', :stored_sortable)}:open"]
      solr_parameters[:"facet.field"] ||= []
      solr_parameters[:"facet.field"] << "organization_type_sim"
      solr_parameters[:rows] = 999999
    end

    def sort_field
      Solrizer.solr_name('institution_name', :sortable)
    end

    def add_sorting_to_solr(solr_parameters)
      return if solr_parameters[:q]
      solr_parameters[:sort] ||= "#{sort_field} asc"
    end

  end
end
