class BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest

  queue_as Hyrax.config.mass_ingest_queue_name

  def perform(ingest, collection_ids, fund_code_id)
    if !ingest['physical_object_id'].present?
      raise "Physical object ID not present for ingest. Ingest: #{ingest}"
    end
#byebug

    all_media = []
    organization_permissions_fields = {}

    imaging_event = nil
    # ingest imaging event
    if ingest['imaging_event'].present?
      imaging_event = Importer::BatchObjectImporter.call(
        'ImagingEvent', 
        ingest['imaging_event'].first[1]['attrs'].merge(
          'physical_object_id' => [ingest['physical_object_id']]
        ).symbolize_keys, 
        nil, 
        false
      )
    else
      raise "Imaging event not present for ingest. Ingest: #{ingest}"
    end

    parent_media = nil
    # ingest parent processing events and media
    ingest['parent'].each do |idx, parent|
      if parent['pe'].present?
        parent_pe = Importer::BatchObjectImporter.call(
          'ProcessingEvent', 
          parent['pe']['attrs'].merge(
            'parent_id' => [imaging_event.id]
          ).symbolize_keys, 
          nil, 
          false
        )
      else
        raise "Required processing event not present for parent media ingest. Ingest: #{parent}"
      end

      if parent['media'].present?
#byebug
        if parent['media']['organization_permissions_fields'].present?
          organization_permissions_fields = parent['media']['organization_permissions_fields']
        end 

#byebug
        parent_media = Importer::BatchObjectImporter.call(
          'Media', 
          parent['media']['attrs'].merge(
            'parent_id' => [parent_pe.id]
          ).symbolize_keys, 
          nil, 
          false
        )

        all_media << parent_media
      else
        raise "Required processing event not present for parent media ingest. Ingest: #{parent}"
      end
    end

    # ingest children processing events and media
    direct_parent = parent_media.presence || imaging_event.presence
#byebug
    if direct_parent.present?
      ingest['children'].each do |idx, child|
#byebug
        if child['pe'].present?
          child_pe = Importer::BatchObjectImporter.call(
            'ProcessingEvent', 
            child['pe']['attrs'].merge(
              'parent_id' => [direct_parent.id]
            ).symbolize_keys, 
            nil, 
            false
          )
        else
          raise "Required processing event not present for child media ingest. Ingest: #{child}"
        end

#byebug
        if child['media'].present?
          if child['media']['organization_permissions_fields'].present?
            organization_permissions_fields = child['media']['organization_permissions_fields']
          end 

          child_media = Importer::BatchObjectImporter.call(
            'Media', 
            child['media']['attrs'].merge(
              'parent_id' => [child_pe.id]
            ).symbolize_keys, 
            nil, 
            false
          )

          all_media << child_media
        else
          raise "Required processing event not present for child media ingest. Ingest: #{child}"
        end
      end
    else
      raise "Required direct parent not present for child media ingest(s). Ingest: #{ingest}"
    end

    # Add org agreement attachment fields
    if all_media.present? && organization_permissions_fields.present? && organization_permissions_fields['organization_for_attachment'].present?
      all_media.each do |media_work|
        Morphosource::AttachmentService.create_copy(media_work.id, 'agreement', organization_permissions_fields['organization_for_attachment'])
      end
    end  

#byebug
    add_media_to_collections(all_media, collection_ids)
    add_media_to_fund_code(all_media, fund_code_id)
  end

  def add_media_to_collections(media, collection_ids)
#byebug
    return unless media.present? && collection_ids.present?
    Array(collection_ids).each do |collection_id|
      c = Collection.find(collection_id)
      c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      c.add_member_objects Array(media).map { |m| m.id }
    end
  end

  def add_media_to_fund_code(media, fund_code_id)
#byebug
    return unless media.present? && fund_code_id.present? && (fc = FundCode.find(fund_code_id))
    media.each do |m|
      m.new_fund_code_association(fc)
    end
  end
end
