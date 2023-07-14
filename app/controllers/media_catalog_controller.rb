# catalog/media
# default catalog view
# catalog/all redirects here for non-admins
class MediaCatalogController < CatalogController
  include CatalogControllerRestApiBehavior

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::MediaCatalogSearchBuilder

    config.max_per_page = 1000000

    # facet fields
    # type
    config.add_facet_field solr_name("human_readable_media_type", :symbol), label: "Type", limit: 10
    # modality - inherited from imaging event modality
    config.add_facet_field solr_name("media_modality", :symbol), label: "Modality", limit: 10
    # object type - specimen or cho
    config.add_facet_field solr_name("media_physical_object_type", :symbol), label: "Object Type", limit: 10
    # organization that owns the object
    config.add_facet_field solr_name("media_organization", :symbol), label: "Organization", limit: 10
    # organization that manages the imaging device
    config.add_facet_field solr_name("media_device_facility_organization", :symbol), label: "Imaging Facility", limit: 10

    # publication status and licensing
    config.add_facet_field solr_name("publication_status", :stored_sortable), label: "Publication", limit: 10
    config.add_facet_field solr_name("rights_statement", :symbol), label: "Rights Statement", limit: 10, helper_method: :rights_statement_title_by_id
    config.add_facet_field solr_name("license", :symbol), label: "CC License", limit: 10, helper_method: :license_title_by_id

    # tags
    config.add_facet_field solr_name("keyword", :facetable), label: "Tag", limit: 10

    # collections
    config.add_facet_field solr_name('member_of_team_ids', :symbol), label: 'Team', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field solr_name('member_of_project_ids', :symbol), label: 'Project', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field solr_name('member_of_media_list_ids', :symbol), label: 'Media List', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field solr_name('member_of_sequential_section_list_ids', :symbol), label: 'Seq. Section List', limit: 10, helper_method: :collection_title_by_id

    # users
    config.add_facet_field solr_name('user_with_ownership_name', :symbol), label: 'Data Manager', limit: 10
    config.add_facet_field solr_name('depositor_name', :symbol), label: 'Data Uploader', limit: 10

    # Search Results Fields
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("physical_object_id", :stored_searchable), label: "Object", helper_method: :link_to_object
    config.add_index_field solr_name("taxonomy", :stored_searchable), label: "Taxonomy"
    config.add_index_field solr_name("part", :stored_searchable), label: "Element or Part"
    config.add_index_field solr_name("media_modality", :stored_searchable), label: "Modality"
    config.add_index_field solr_name("member_of_sequential_section_list_ids", :symbol), label: "Sequential Section List", helper_method: :link_to_sequential_section_lists
    config.add_index_field solr_name("user_with_ownership", :stored_sortable), label: "Data Manager", helper_method: :link_to_profile
    config.add_index_field solr_name("date_uploaded", :stored_sortable, type: :date), label: "Date Uploaded", helper_method: :human_readable_date
    config.add_index_field solr_name("publication_status", :stored_sortable), label: "Publication Status"
    config.add_index_field solr_name("rights_statement", :symbol), label: "Rights Statement", helper_method: :rights_statement_links
    config.add_index_field solr_name("license", :symbol), label: "CC License", helper_method: :license_links
    

    # solr fields to be displayed in the show (single result) view
    # these fields also determine what fields are indexed for searching
    config.add_show_field solr_name('agreement_uri', :stored_searchable)
    config.add_show_field solr_name('cite_as', :stored_searchable)
    config.add_show_field solr_name('funding', :stored_searchable)
    config.add_show_field solr_name('map_type', :stored_searchable)
    config.add_show_field solr_name('media_modality', :stored_searchable)
    config.add_show_field solr_name('media_organization', :stored_searchable)
    config.add_show_field solr_name('media_device_facility_organization', :stored_searchable)
    config.add_show_field solr_name('media_physical_object_type', :stored_searchable)
    config.add_show_field solr_name('media_type', :stored_searchable)
    config.add_show_field solr_name("member_of_collections", :symbol)
    config.add_show_field solr_name('orientation', :stored_searchable)
    config.add_show_field solr_name('part', :stored_searchable)
    config.add_show_field solr_name('physical_object_id', :stored_searchable)
    config.add_show_field solr_name('physical_object_title', :stored_searchable)
    config.add_show_field solr_name('physical_object_title', :symbol)
    config.add_show_field solr_name('institution_code', :stored_searchable)
    config.add_show_field solr_name('institution_code', :symbol)
    config.add_show_field solr_name('collection_code', :stored_searchable)
    config.add_show_field solr_name('collection_code', :symbol)
    config.add_show_field solr_name('catalog_number', :stored_searchable)
    config.add_show_field solr_name('catalog_number', :symbol)
    config.add_show_field solr_name('occurrence_id', :stored_searchable)
    config.add_show_field solr_name('occurrence_id', :symbol)
    config.add_show_field solr_name('ark', :symbol)
    config.add_show_field solr_name('doi', :symbol)
    config.add_show_field solr_name('rights_holder', :stored_searchable)
    config.add_show_field solr_name('scale_bar', :stored_searchable)
    config.add_show_field solr_name('series_type', :stored_searchable)
    config.add_show_field solr_name('short_description', :stored_searchable)
    config.add_show_field solr_name('side', :stored_searchable)
    config.add_show_field solr_name('slice_thickness', :stored_searchable)
    config.add_show_field solr_name('taxonomy', :stored_searchable)
    config.add_show_field solr_name('unit', :stored_searchable)
    config.add_show_field solr_name('x_spacing', :stored_searchable)
    config.add_show_field solr_name('y_spacing', :stored_searchable)
    config.add_show_field solr_name('z_spacing', :stored_searchable)
    config.add_show_field solr_name('doi', :stored_searchable)
    config.add_show_field solr_name('ark', :stored_searchable)
    config.add_show_field solr_name('user_with_ownership_name', :stored_searchable)
    config.add_show_field solr_name('depositor_name', :stored_searchable)

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
    @response, @document = fetch params[:id], { fq: 'has_model_ssim:Media' }

    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { @document.has_model.first.underscore => @document.to_semantic_values } } }
      additional_export_formats(@document, format)
    end
  end

  def document_type
    'media'
  end
end
