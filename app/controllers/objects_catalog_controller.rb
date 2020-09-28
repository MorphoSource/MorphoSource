# catalog/objects
class ObjectsCatalogController < CatalogController

  # self.access_controlled_facets = ['media_member_of_collection_ids_ssim', 'media_type_ids_ssim', 'media_keyword_ids_ssim']

  # get search results from the solr index
  def index
    (@response, @document_list) = search_results(params)
    byebug
    # remove_hidden_facet_items
    remove_hidden_child_facet_items
    respond_to do |format|
      format.html { store_preferred_view }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        @presenter = Blacklight::JsonPresenter.new(@response,
                                                   @document_list,
                                                   facets_from_request,
                                                   blacklight_config)
      end
      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  # displays values and pagination links for a single facet field
    def facet
      byebug
      @facet = blacklight_config.facet_fields[params[:id]]
      raise ActionController::RoutingError, 'Not Found' unless @facet
      @response = get_facet_field_response(@facet.key, params)
      @display_facet = @response.aggregations[@facet.field]
      remove_hidden_children_display_facet      @pagination = facet_paginator(@facet, @display_facet)
      byebug
      respond_to do |format|
        format.html do
          # Draw the partial for the "more" facet modal window:
          return render layout: false if request.xhr?
          # Otherwise draw the facet selector for users who have javascript disabled.
        end
        format.json
      end
    end


  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::ObjectsCatalogSearchBuilder

    # facets
    # type facet (specimen or cho)
    # config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
    # creator
    config.add_facet_field solr_name("creator", :facetable), label: "Creator", limit: 5
    # organization
    # config.add_facet_field solr_name("organization", :facetable), label: "Organization", limit: 5
    # media types
    config.add_facet_field "media_type_ids_ssim", label: "Media Type Ids", limit: 5
    config.add_facet_field "media_type_sim", label: "Media Type", limit: 5
    # media collection
    # config.add_facet_field "media_member_of_collection_ids_ssim", limit: 5, label: "Media Team / Project", helper_method: :collection_title_by_id
    # media tag
    config.add_facet_field "media_keyword_ids_ssim", label: "Media Tag Ids", limit: 999999
    config.add_facet_field "media_keyword_sim", label: "Media Tag", limit: 5
  end
end
