class BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob < Morphosource::ApplicationJobWithStatus
  attr_accessor :manifest, :main_job_id

  queue_as Hyrax.config.mass_ingest_queue_name
  #queue_as Hyrax.config.batch_submission_queue_name

  def perform(manifest, ingest, ingest_index, collection_ids, fund_code_id, target_parent_id, job_id)
    status.update(manifest: manifest)
    @manifest = manifest
    @main_job_id = job_id

    if !ingest['physical_object_id'].present?
      raise "Physical object ID not present for ingest. Ingest: #{ingest}"
    end

    all_media = []
    organization_permissions_fields = {}
    created_media = {}

    imaging_event = nil
    # ingest imaging event
    if ingest['imaging_event'].present?
      imaging_event = BatchSubmissionsImporter::BatchObjectImporter.call(
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
    if ingest['parent'].present?
      ingest['parent'].each do |idx, parent|

        if target_parent_id.present? 
          # the media has been created as a child media earlier
          parent_media = Media.find(target_parent_id)
          next
        end

        if parent['media']['id'].present? 
          # parent media is existing.  get the obj and skip (no need to create)
          parent_media = Media.find(parent['media']['id'])
          next
        end
        if parent['media']['initial_attrs']['raw_or_derived']&.first == "Raw"
          is_raw = true
        else
          is_raw = false
          if parent['pe'].present?
            parent_pe = BatchSubmissionsImporter::BatchObjectImporter.call(
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
        end

        if parent['media'].present?
          if parent['media']['initial_attrs']['preview_file'].present? &&
              parent['media']['media_path'].present?
            # this is where preview_file is set
            preview_file = parent['media']['media_path'] + parent['media']['initial_attrs']['preview_file'].first
          end

          if is_raw
            parent_media = BatchSubmissionsImporter::BatchObjectImporter.call(
              'Media', 
              parent['media']['attrs'].merge(
                'parent_id' => [imaging_event.id]
              ).symbolize_keys, 
              nil,
              false,
              preview_file
            )
          else
            parent_media = BatchSubmissionsImporter::BatchObjectImporter.call(
              'Media', 
              parent['media']['attrs'].merge(
                'parent_id' => [parent_pe.id]
              ).symbolize_keys, 
              nil,
              false,
              preview_file
            )
          end

          media_file = parent['media']['initial_attrs']['media_file'].first
          created_media[media_file] = parent_media.id
          Rails.logger.debug "iN MediaIePeIngestJob: parent media created: #{parent_media.id} "

          all_media << parent_media
        else
          raise "Required parent media not present for parent media ingest. Ingest: #{parent}"
        end
      end
    end

    # ingest children processing events and media
    direct_parent = parent_media.presence || imaging_event.presence
    if direct_parent.present?
      ingest['children'].each do |idx, child|
        if child['pe'].present?
          # associate with the direct parent
          child_pe = BatchSubmissionsImporter::BatchObjectImporter.call(
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

        if child['media'].present?
          if child['media']['initial_attrs']['preview_file'].present? &&
              child['media']['media_path'].present?
            # this is where preview_file is set
            preview_file = child['media']['media_path'] + child['media']['initial_attrs']['preview_file'].first
          end

          Rails.logger.debug "iN MediaIePeIngestJob: creating child media... "

          child_media = BatchSubmissionsImporter::BatchObjectImporter.call(
            'Media', 
            child['media']['attrs'].merge(
              'parent_id' => [child_pe.id]
            ).symbolize_keys, 
            nil, 
            false,
            preview_file
          )

          media_file = child['media']['initial_attrs']['media_file'].first
          created_media[media_file] = child_media.id
          Rails.logger.debug "iN MediaIePeIngestJob: child media created: #{child_media.id} "

          all_media << child_media
        else
          raise "Required media not present for child media ingest. Ingest: #{child}"
        end
      end
    else
      raise "Required direct parent not present for child media ingest(s). Ingest: #{ingest}"
    end

    main_job = BackgroundJob.where(job_id: @main_job_id).first
    Rails.logger.debug "iN MediaIePeIngestJob:  updating job #{main_job.job_id} with created_media #{created_media}" 
    main_job.update_created_objects(created_media)

    # Add org agreement attachment fields
    if all_media.present? && organization_permissions_fields.present? && organization_permissions_fields['organization_for_attachment'].present?
      all_media.each do |media_work|
        Morphosource::AttachmentService.create_copy(media_work.id, 'agreement', organization_permissions_fields['organization_for_attachment'])
      end
    end  

    add_media_to_collections(all_media, collection_ids)
    add_media_to_fund_code(all_media, fund_code_id)
    
    UpdateWorkIndexJob.perform_later(ingest['physical_object_id'])

    # look for dependent child 
  end

  def add_media_to_collections(media, collection_ids)
    return unless media.present? && collection_ids.present?
    Array(collection_ids).each do |collection_id|
      c = Collection.find(collection_id)
      c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      c.add_member_objects Array(media).map { |m| m.id }
    end
  end

  def add_media_to_fund_code(media, fund_code_id)
    return unless media.present? && fund_code_id.present? && (fc = FundCode.find(fund_code_id))
    media.each do |m|
      m.new_fund_code_association(fc)
    end
  end
end
