# catalog/teams_projects
class MediaListsCatalogController < CatalogController
  include CatalogControllerRestApiBehavior
  include Morphosource::CatalogHelper

  def catalog_search_form_action
    main_app.media_list_search_path
  end

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::MediaListsCatalogSearchBuilder

    # facet fields
    config.add_facet_field "type", field: "human_readable_type_sim", label: "List Type", limit: 10

    # search result metadata
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("description", :stored_searchable), label: "Description", helper_method: :line_clamp
    config.add_index_field solr_name("creator", :stored_searchable), label: "Creator", helper_method: :link_to_creator
    # for some reason the label is not getting rendered correctly in the catalog. For now, overriding in _index_list_default
    config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), label: "Date Created", helper_method: :human_readable_date

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

  # get a single document from the index
  # to add responses for formats other than html or json see _Blacklight::Document::Export_
  def show
    @response, @document = search_service.fetch params[:id], { fq: 'has_model_ssim:(MediaList OR SequentialSectionList)' }

    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { @document.has_model.first.underscore => @document.to_semantic_values } } }
      additional_export_formats(@document, format)
    end
  end

  def document_type
    'list'
  end
end
