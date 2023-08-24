# catalog/objects
class ObjectsCatalogController < CatalogController
  include CatalogControllerRestApiBehavior

  configure_blacklight do |config|
    config.search_builder_class = Morphosource::Catalog::ObjectsCatalogSearchBuilder
    # disable thumbnails
    config.index.thumbnail_field = ''

    # facets
    # type facet (specimen or cho)
    config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 10
    # creator
    config.add_facet_field solr_name("creator", :facetable), label: "Creator", limit: 10
    # organization
    config.add_facet_field "organization_ssim", label: "Organization", limit: 10
    # external taxonomy
    config.add_facet_field "external_taxonomy_ssim", label: "Taxonomy (GBIF)", limit: 25
    # media types
    config.add_facet_field "public_media_type_ssim", label: "Media Type", limit: 10
    # media tag
    config.add_facet_field "public_media_keyword_ssim", label: "Media Tag", limit: 10
    # media collection
    config.add_facet_field solr_name('media_member_of_team_ids', :symbol), label: 'Team', limit: 10, helper_method: :collection_title_by_id
    config.add_facet_field solr_name('media_member_of_project_ids', :symbol), label: 'Project', limit: 10, helper_method: :collection_title_by_id

    # search results display fields
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
    config.add_index_field solr_name("taxonomy", :stored_searchable), label: "Taxonomy"
    config.add_index_field solr_name("organization", :stored_searchable), label: "Organization"
    config.add_index_field solr_name("human_readable_type", :stored_searchable), label: "Type"
    # do not show if object is a cho
    # defined on the solr document model at Morphosource::SolrDocumentBehavior
    config.add_index_field 'source', accessor: 'object_record_source', if: lambda { |context, field_config, document|
      document.specimen?
    }
    # media count displayed from _index_list_default
    # method total_viewable_media in Morphosource::PresenterMethods

    # solr fields to be displayed in the show (single result) view
    # these fields also determine what fields are indexed for searching
    config.add_show_field solr_name('human_readable_type', :stored_searchable)
    config.add_show_field solr_name('bibliographic_citation', :stored_searchable)
    config.add_show_field solr_name('catalog_number', :stored_searchable)
    config.add_show_field solr_name('collection_code', :stored_searchable)
    config.add_show_field solr_name('institution_code', :stored_searchable)
    config.add_show_field solr_name('current_location', :stored_searchable)
    config.add_show_field solr_name('numeric_time', :stored_searchable)
    config.add_show_field solr_name('original_location', :stored_searchable)
    config.add_show_field solr_name('periodic_time', :stored_searchable)
    config.add_show_field solr_name('vouchered', :stored_searchable)

    # Biological Specimens
    config.add_show_field solr_name('idigbio_recordset_id', :stored_searchable)
    config.add_show_field solr_name('idigbio_uuid', :stored_searchable)
    config.add_show_field solr_name('is_type_specimen', :stored_searchable)
    config.add_show_field solr_name('occurrence_id', :stored_searchable)
    config.add_show_field solr_name('sex', :stored_searchable)
    config.add_show_field solr_name('taxonomy', :stored_searchable)

    # CHOs
    config.add_show_field solr_name('cho_type', :stored_searchable)
    config.add_show_field solr_name('material', :stored_searchable)
    config.add_show_field solr_name('short_title', :stored_searchable)

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
    @response, @document = fetch params[:id], { fq: 'has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)' }

    respond_to do |format|
      format.html { setup_next_and_previous_documents }
      format.json { render json: { response: { @document.has_model.first.underscore => @document.to_semantic_values } } }
      additional_export_formats(@document, format)
    end
  end

  def document_type
    'physical_object'
  end
end
