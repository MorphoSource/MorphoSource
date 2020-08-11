module Hyrax
  class MyTeamController < MyController

    # Define filter facets that apply to all repository objects.
    def self.configure_facets
      # clear facet's copied from the CatalogController
      blacklight_config.facet_fields = {}
      configure_blacklight do |config|
        # TODO: add a visibility facet (requires visibility to be indexed)
        config.add_facet_field solr_name('visibility', :stored_sortable),
                               helper_method: :visibility_badge,
                               limit: 5, label: I18n.t('hyrax.dashboard.my.heading.visibility')
        config.add_facet_field IndexesWorkflow.suppressed_field, helper_method: :suppressed_to_status
        config.add_facet_field solr_name("resource_type", :facetable), limit: 5
      end
    end

    with_themed_layout 'morphosource_dashboard'


  end
end
