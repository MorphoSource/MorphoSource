# catalog/media
# default catalog view
# catalog/all redirects here for non-admins
class MediaCatalogController < CatalogController
  include CatalogControllerRestApiBehavior
  include Morphosource::CatalogHelper

  # This filter applies the hydra access controls to media file details API endpoint
  before_action :enforce_show_permissions, only: [:show, :show_file_metadata]

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::MediaCatalogSearchBuilder

    # facet fields
    config.add_facet_field "media_type", field: "human_readable_media_type_ssim", label: "Media Type", limit: 10
    config.add_facet_field "modality", field: "modality_ssim", label: "Modality", limit: 10, helper_method: :modality_label_by_id
    config.add_facet_field "object_type", field: "media_physical_object_type_ssim", label: "Object Type", limit: 10
    config.add_facet_field "organization", field: "media_organization_ssim",label: "Organization", limit: 10
    config.add_facet_field "imaging_facility", field: "media_device_facility_organization_ssim", label: "Imaging Facility", limit: 10
    config.add_facet_field "publication_status", field: "publication_status_ssi", label: "Publication Status", limit: 10
    config.add_facet_field "rights_statement", field: "rights_statement_ssim", label: "Rights Statement", limit: 10, helper_method: :rights_statement_title_by_id
    config.add_facet_field "license", field: "license_ssim", label: "CC License",limit: 10, helper_method: :license_title_by_id
    config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
    config.add_facet_field "taxonomy_gbif", field: "external_taxonomy_ssim", label: "Taxonomy (GBIF)", limit: 25
    config.add_facet_field "tag", field: "keyword_ssim", label: "Tag", limit: 10
    config.add_facet_field "team", field: "member_of_team_ids_ssim", label: 'Team', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field "project", field: "member_of_project_ids_ssim", label: 'Project', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field "media_list", field: "member_of_media_list_ids_ssim", label: 'Media List', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field "seq_section_list", field: "member_of_sequential_section_list_ids_ssim", label: 'Seq. Section List', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field "owner", field: "user_with_ownership_name_ssim", label: 'Data Manager', limit: 10
    config.add_facet_field "depositor", field: "depositor_name_ssim", label: 'Data Uploader', limit: 10
    config.add_facet_field "sponsor", field: "active_fund_code_title_ssim", label: 'Data Sponsor', limit: 10

    # Search Results Fields
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("physical_object_id", :stored_searchable), label: "Object", helper_method: :link_to_object
    config.add_index_field solr_name("taxonomy", :stored_searchable), label: "Taxonomy", helper_method: :italicize_taxonomy
    config.add_index_field solr_name("part", :stored_searchable), label: "Element or Part"
    config.add_index_field solr_name("human_readable_modality", :stored_searchable), label: "Modality"
    config.add_index_field solr_name("member_of_sequential_section_list_ids", :symbol), label: "Sequential Section List", if: :can_read_any, helper_method: :link_to_sequential_section_lists
    config.add_index_field solr_name("user_with_ownership", :stored_sortable), label: "Data Manager", helper_method: :link_to_user_with_ownership
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
    config.add_show_field solr_name('human_readable_modality', :stored_searchable)
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

  # an API route for returning media file object details using catalog
  def show_file_metadata
    @response, @document = fetch params[:id], { fq: "has_model_ssim:Media", fl: ["id", "file_set_ids_ssim"] }
    _, @fileset_documents = fetch ( @document["file_set_ids_ssim"] || [] ), { fq: "has_model_ssim:FileSet" }
    @fileset_document = @fileset_documents&.first

    response = @fileset_document.present? ? 
      { @fileset_document.has_model.first.underscore => @fileset_document.to_semantic_values } : {}

    respond_to do |format|
      format.json { render json: { response: response } }
      additional_export_formats(@document, format)
    end
  end

  def document_type
    'media'
  end
end
