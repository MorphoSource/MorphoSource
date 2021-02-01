module CollectionInformationHelper
  # Methods for collection information services

  ### Solr collection queries

  # Team-specific #

  def organization_po_ids(organization_id=nil)
    o_id = organization_id || @collection_organization_id
    return [] if !o_id.present?

    params = {
      fl: ['id'],
      fq: [
        "#{solrize('organization_id', :stored_searchable)}:#{o_id}",
        "(#{solrize('has_model', :symbol)}:BiologicalSpecimen OR #{solrize('has_model', :symbol)}:CulturalHeritageObject)"
      ]
    }
    solr.get_docs(nil, params).map { |d| d['id'] }
  end

  def team_origin_count
    # counting team projects + team
    params = {
      rows: 0,
      fq: [
        assemble_or_query(solrize('member_of_collection_ids', :symbol), get_subcollection_ids([collection_id]) + [collection_id]),
        "#{solrize('has_model', :symbol)}:Media"
      ]
    }
    solr.get(nil, params)
    solr.count
  end

  def team_org_origin_count
    params = {
      rows: 0,
      fq: [
        assemble_po_id_or_collection_query(@team_org_po_ids, collection_id),
        "#{solrize('has_model', :symbol)}:Media"
      ]
    }
    solr.get(nil, params)
    solr.count
  end

  def get_subcollection_ids(collection_ids)
    params = {
      fl: ['id'],
      fq: [
        assemble_or_query(solrize('nesting_collection__parent_ids', :symbol), Array(collection_ids)),
        "#{solrize('has_model', :symbol)}:Collection"
      ]
    }
    solr.get_docs(nil, params).map { |d| d['id'] }
  end

  # Other solr queries #

  def is_project?(collection_type)
    collection_type.split('/').last == '2'
  end

  def is_team?(collection_type)
    collection_type.split('/').last == '1'
  end

  def bso_idigbio_count
    return 0 if !@bso_ids.present?

    params = {
      rows: 0,
      fq: [
        assemble_or_query('id', @bso_ids.map { |id| prepare_value(id) } ),
        "#{solrize('idigbio_uuid', :stored_searchable)}:*"
      ] 
    }

    solr.get(nil, params)
    solr.count
  end

  def physical_object_counts_by_organization
    # hash of physical object counts by organization IDs
    return {} if !@physical_object_ids.present?

    facet_fields = [solrize('organization_id', :stored_searchable)]

    bso_params = {
      rows: 0,
      fq: [
        "#{solrize('has_model', :symbol)}:BiologicalSpecimen",
        assemble_or_query('id', @physical_object_ids.map { |id| id.upcase } )
      ],
      "facet.limit": -1
    }
    cho_params = {
      rows: 0,
      fq: [
        "#{solrize('has_model', :symbol)}:CulturalHeritageObject",
        assemble_or_query('id', @physical_object_ids.map { |id| id.upcase } )
      ],
      "facet.limit": -1
    }

    solr.get_facet_fields(nil, facet_fields, bso_params)
    bso_facets = solr.facet_fields(facet_fields)[facet_fields[0]]
      .transform_keys(&:upcase)
      .transform_values { |v| { bso: v } }

    solr.get_facet_fields(nil, facet_fields, cho_params)
    cho_facets = solr.facet_fields(facet_fields)[facet_fields[0]]
      .transform_keys(&:upcase)
      .transform_values { |v| { cho: v } }
    
    bso_facets.deep_merge(cho_facets)
  end

  def organization_docs(organization_title = '')
    return [] if !@po_counts_by_org.present?

    # solr docs of organizations corresponding to physical object IDs
    params = {
      fl: ['id', solrize('title', :stored_searchable)].join(','),
      fq: [
        solrize('has_model', :symbol) + ':Organization', 
        assemble_or_query('id', @po_counts_by_org.keys.map { |id| id.upcase } )
      ]
    }
    params[:fq] += ["#{solrize('title', :stored_searchable)}:#{prepare_value(organization_title)}"] if organization_title.present?

    solr.get_docs(nil,  params)
  end

  def po_ids_by_model(po_ids, model)
    return [] if !po_ids.present?

    params = {
      fl: 'id',
      fq: [
        assemble_or_query('id', po_ids),
        "#{solrize('has_model', :symbol)}:#{model}"
      ]
    }

    solr.get_docs(nil, params).map(&:values).flatten
  end

  ### Collection information parsing ###

  def map_media_type(t)
    case t
      when 'ctimagesery' then 'CTImageSeries'
      when 'photogrammetryimagesery' then 'PhotogrammetryImageSeries'
      else t.titleize
    end
  end

  def bso_source_groups
    if @n_idigbio.present?
      { 'source' => { 
        'idigbio' => @n_idigbio, 
        'user' => @physical_object_ids.length - @n_idigbio
      } }
    else 
      {}
    end
  end

  def info_po_media_counts_by_organization
    org_media_counts = @facet_results[solrize('media_organization_id', :symbol)].transform_keys(&:upcase)
    
    @organizations.each do |o|
      if org_media_counts.present? && org_media_counts.key?(o['id'])
        @info['media_groups']['organization'][o['title_tesim']&.first] = org_media_counts[o['id']]
      end

      if @po_counts_by_org.present? && @po_counts_by_org.key?(o['id'])
        if @po_counts_by_org[o['id']][:bso].present?
          @info['bso_groups']['organization'][o['title_tesim']&.first] = @po_counts_by_org[o['id']][:bso]
        end

        if @po_counts_by_org[o['id']][:cho].present?
          @info['cho_groups']['organization'][o['title_tesim']&.first] = @po_counts_by_org[o['id']][:cho]
        end
      end
    end
  end

  ### Collection solrize filter params ###

  def po_ids_by_collection_title(collection_title)
    return [] if !collection_title.present?
    params = { 
      fl: ['physical_object_id_tesim'],
      fq: [
        solrize('has_model', :symbol) + ':Media',
        "#{solrize('member_of_collections', :symbol)}:#{prepare_value(collection_title)}"
      ]
    }
    media = solr.get_docs(nil, params)
    filtered_title_po_ids =  media.map { |o| o['physical_object_id_tesim'] }.flatten.compact.uniq
    return filtered_title_po_ids
  end

  def po_ids_by_collection_organization(title)
    return [] if !title.present?

    organizations = organization_docs(title)
    filtered_org_po_ids = organizations.
      map { |o| organization_po_ids(o['id']) }.
      flatten.uniq.map(&:upcase)
    
    @physical_object_ids.select { |po_id| filtered_org_po_ids.include? po_id }
  end

end