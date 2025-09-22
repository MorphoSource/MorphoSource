# catalog/organizations
class OrganizationsCatalogController < CatalogController
  include CatalogControllerRestApiBehavior

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::OrganizationsCatalogSearchBuilder
    # disable thumbnails
    config.index.thumbnail_field = ''

    # facet fields
    config.add_facet_field "organization_type", field: "organization_type_ssim", label: "Organization Type", limit: 10
    config.add_facet_field "institution_name", field: "institution_name_ssim", label: "Institution Name", limit: 10
    config.add_facet_field "institution_code", field: "institution_code_ssim", label: "Institution Code", limit: 10
    config.add_facet_field "country", field: "country_ssim", label: "Country", limit: 10
    config.add_facet_field "state_province", field: "state_province_ssim", label: "State/Province", limit: 10
    config.add_facet_field "city", field: "city_ssim", label: "City", limit: 10

    # search results display fields
    config.add_index_field solr_name("organization_type", :stored_searchable), label: "Type"
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("institution_name", :stored_searchable), label: "Institution"
    config.add_index_field solr_name("institution_code", :stored_searchable), label: "Institution Code"
    config.add_index_field solr_name("collection_code", :stored_searchable), label: "Collection Code"
    config.add_index_field solr_name("country", :stored_searchable), label: "Country"
    config.add_index_field solr_name("description", :stored_searchable), label: "Description", helper_method: :line_clamp
    # linked team displayed from _index_list_default
    # method linked_team in Hyrax::OrganizationPresenter

    # solr fields to be displayed in the show (single result) view
    # these fields also determine what fields are indexed for searching
    config.add_show_field solr_name('collection_code', :stored_searchable)
    config.add_show_field solr_name('institution_code', :stored_searchable)
    config.add_show_field solr_name('institution_name', :stored_searchable)

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = solr_name("title", :stored_searchable)
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv id",
        pf: title_name.to_s
      }
    end
  end

  def show
    @response, @document = search_service.fetch params[:id], { fq: 'has_model_ssim:Organization' }

    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { @document.has_model.first.underscore => @document.to_semantic_values } } }
      additional_export_formats(@document, format)
    end
  end

  def document_type
    'organization'
  end
end
