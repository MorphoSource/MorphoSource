module Morphosource
  class DeviceMediaSearchBuilder < Morphosource::PhysicalObjectMediaSearchBuilder

    include Morphosource::OrganizationalAccessBehavior

    self.object_id_field = 'media_device_id_ssim'

    self.default_processor_chain += [:return_selected_fields, :add_custom_facet_fields, :add_custom_facet_limit]

    # Return only the fields we need instead of the entire document
    # In this case, we only need the document count and imaging event IDs.
    def return_selected_fields(solr_parameters)
      if !@blacklight_params[:return_all_fields]
        solr_parameters[:fl] = 'id,imaging_event_id_ssim,imaging_event_id_tesim'
      end
    end

    # Add facets not included in controller blacklight configuration
    def add_custom_facet_fields(solr_parameters)
      custom_facets.each do |facet|
        solr_parameters["facet.field"] << facet
      end
    end

    def add_custom_facet_limit(solr_parameters)
      solr_parameters["facet.limit"] = custom_facet_limit
    end

    # List of custom facets to add to the search
    def custom_facets
      ["imaging_event_id_ssim"]
    end

    # override default facet limit
    def custom_facet_limit
      999_999
    end
  end
end
