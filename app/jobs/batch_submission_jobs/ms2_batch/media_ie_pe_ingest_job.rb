class BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob < Morphosource::ApplicationJobWithStatus
  include BatchSubmissionTools::Ms2Batch::BatchSubmission
  attr_accessor :background_job_id

  queue_as Hyrax.config.mass_ingest_queue_name
  #queue_as Hyrax.config.batch_submission_queue_name

  def perform(
    background_job_id,
    ingest,
    collection_ids,
    fund_code_id,
    organization_transfer_immediately,
    target_parent_id
  )
    @background_job_id = background_job_id
    @organization_id = background_job_manifest["biological_specimen_ingests"].first["organization_id"]

    # debug: check ingest['parent']
    if !ingest['physical_object_id'].present?
      raise "Physical object ID not present for ingest. Ingest: #{ingest}"
    end

    all_media = []
    organization_permissions_fields = {}
    created_objects = background_job.created_objects

    imaging_event = nil
    # ingest imaging event
    if ingest['imaging_event'].present?
      ie_row_index = ingest['imaging_event'].first[0]
      ie_key = "ie_#{ie_row_index}"
      if created_objects[ie_key].present? && imaging_event_exists?(created_objects[ie_key])
        imaging_event = OpenStruct.new(id: created_objects[ie_key])
      else
        imaging_event = BatchSubmissionsImporter::BatchObjectImporter.call(
          'ImagingEvent',
          ingest['imaging_event'].first[1]['attrs'].merge(
            'physical_object_id' => [ingest['physical_object_id']]
          ).symbolize_keys,
          nil,
          false
        )
        created_objects[ie_key] = imaging_event.id
        background_job.update_created_objects(created_objects)
      end
    else
      raise "Imaging event not present for ingest. Ingest: #{ingest}"
    end

    parent_media = nil
    # ingest parent processing events and media
    # debug: check ingest['parent']
    if ingest['parent'].present?
      ingest['parent'].each do |idx, parent|

        if target_parent_id.present?
          # the media has been created as a child media earlier
          parent_media = Media.find(target_parent_id)
          next
        end

        if parent['media']['id'].present?
          # parent media is existing.  get the work and skip (no need to create)
          parent_media = Media.find(pad(parent['media']['id']))
          next
        end

        parent_media_key = "parent_media_#{idx}"
        if created_objects[parent_media_key].present? && media_exists?(created_objects[parent_media_key])
          parent_media = Media.find(created_objects[parent_media_key])
          all_media << parent_media
          next
        end

        if parent['media']['initial_attrs']['raw_or_derived']&.first.downcase == "raw"
          is_raw = true
        else
          is_raw = false
          parent_pe_key = "parent_pe_#{idx}"
          if created_objects[parent_pe_key].present? && processing_event_exists?(created_objects[parent_pe_key])
            parent_pe = OpenStruct.new(id: created_objects[parent_pe_key])
          elsif parent['pe'].present?
            parent_pe = BatchSubmissionsImporter::BatchObjectImporter.call(
              'ProcessingEvent',
              parent['pe']['attrs'].merge(
                'parent_id' => [imaging_event.id]
              ).symbolize_keys,
              nil,
              false
            )
            created_objects[parent_pe_key] = parent_pe.id
            background_job.update_created_objects(created_objects)
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

          # debug: check parent['media']['attrs']
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

          created_objects[parent_media_key] = parent_media.id
          # Also write filename key so check_and_wait_for_parent_media can find this media
          parent_media_file = parent['media']['initial_attrs']['media_file']&.first
          created_objects[parent_media_file] = parent_media.id if parent_media_file.present?
          Rails.logger.debug "iN MediaIePeIngestJob: parent media created: #{parent_media.id} "
          Rails.logger.debug "iN MediaIePeIngestJob: updating background job #{background_job_id} with created_objects #{created_objects}"
          background_job.update_created_objects(created_objects)

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
        child_pe_key = "child_pe_#{idx}"
        child_media_key = "child_media_#{idx}"

        if child['pe'].present?
          if created_objects[child_pe_key].present? && processing_event_exists?(created_objects[child_pe_key])
            child_pe = OpenStruct.new(id: created_objects[child_pe_key])
          else
            # associate with the direct parent
            child_pe = BatchSubmissionsImporter::BatchObjectImporter.call(
              'ProcessingEvent',
              child['pe']['attrs'].merge(
                'parent_id' => [direct_parent.id]
              ).symbolize_keys,
              nil,
              false
            )
            created_objects[child_pe_key] = child_pe.id
            background_job.update_created_objects(created_objects)
          end
        else
          raise "Required processing event not present for child media ingest. Ingest: #{child}"
        end

        if child['media'].present?
          if created_objects[child_media_key].present? && media_exists?(created_objects[child_media_key])
            child_media = Media.find(created_objects[child_media_key])
          else
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

            created_objects[child_media_key] = child_media.id
            # Also write filename key so check_and_wait_for_parent_media can find this media
            child_media_file = child['media']['initial_attrs']['media_file']&.first
            created_objects[child_media_file] = child_media.id if child_media_file.present?
            Rails.logger.debug "iN MediaIePeIngestJob: child media created: #{child_media.id} "
            Rails.logger.debug "iN MediaIePeIngestJob: updating background job #{@background_job_id} with created_objects #{created_objects}"
            background_job.update_created_objects(created_objects)
          end

          all_media << child_media
        else
          raise "Required media not present for child media ingest. Ingest: #{child}"
        end
      end
    else
      raise "Required direct parent not present for child media ingest(s). Ingest: #{ingest}"
    end

    add_media_to_collections(all_media, collection_ids)
    add_media_to_fund_code(all_media, fund_code_id)
    transfer_media_to_organization(all_media, organization_transfer_immediately)
    add_org_attachment_to_media(all_media, @organization_id) if @organization_id.present?

    UpdateWorkIndexJob.perform_later(ingest['physical_object_id'])
    # update index for each media here since they are not indexed properly after Hyrax 3 update
    all_media.each do |m|
      UpdateWorkIndexJob.perform_later(m.id)
    end
    # re-index parent media if it was created in a separate ingest (not included in all_media)
    if parent_media.present? && !all_media.include?(parent_media)
      UpdateWorkIndexJob.perform_later(parent_media.id)
    end
  end

  # post-media creation methods

  def add_media_to_collections(media, collection_ids)
    return unless media.present? && collection_ids.present?
    Array(media).each do |m|
      ModifyCollectionMembershipJob.perform_later(media_id: m.id, add_to_collection_ids: Array(collection_ids))
    end
  end

  def add_media_to_fund_code(media, fund_code_id)
    return unless media.present? && fund_code_id.present? && (fc = FundCode.find(fund_code_id))
    media.each do |m|
      next if m.fund_codes.where(id: fc.id).present?
      m.new_fund_code_association(fc)
    end
  end

  def transfer_media_to_organization(media, organization_transfer_immediately)
    return unless media.present? && organization_transfer_immediately == true

    if !organization_allows_media_ownership_transfer?(media)
      Rails.logger.info "iN MediaIePeIngestJob: organization does not allow media ownership transfer. Skipping transfer for media #{media.map(&:id)} "
      return
    end

    media.each do |m|
      if ProxyDepositRequest.where(work_id: m.id, organization_transfer: true).exists?
        Rails.logger.info "iN MediaIePeIngestJob: skipping transfer for media #{m.id} - org transfer already initiated or completed"
        next
      end
      Rails.logger.info "iN MediaIePeIngestJob: enqueuing TransferToOrganizationJob for media #{m.id} "
      TransferToOrganizationJob.perform_later(m.id)
    end
  end

  def organization_allows_media_ownership_transfer?(media)
    org_id = @organization_id || media.first&.organization_id&.first
    return false unless org_id.present?

    org_doc = SolrDocument.find(org_id)
    return false unless org_doc.present?

    if org_doc.organization?
      org_doc["data_manager_tesim"].present?
    else
      org_doc["media_ownership_transfer_bsi"] == true
    end
  end

  def add_org_attachment_to_media(media, org_id)
    org = Organization.where(id: org_id)&.first || OrganizationCollection.where(id: org_id)&.first

    if org.present? && org.agreement_attachment_url.present?
      media.each do |m|
        next if m.agreement_attachment_url.present?
        CopyOrganizationAgreementAttachmentJob.perform_later(m.id, org.id)
      end
    end
  end

  def imaging_event_exists?(id)
    return false unless id.present?
    @imaging_event_works_cache ||= {}
    @imaging_event_works_cache[id] = ImagingEvent.exists?(id) unless @imaging_event_works_cache.key?(id)
    @imaging_event_works_cache[id]
  end

  def processing_event_exists?(id)
    return false unless id.present?
    @processing_event_works_cache ||= {}
    @processing_event_works_cache[id] = ProcessingEvent.exists?(id) unless @processing_event_works_cache.key?(id)
    @processing_event_works_cache[id]
  end

  def media_exists?(id)
    return false unless id.present?
    @media_works_cache ||= {}
    @media_works_cache[id] = Media.exists?(id) unless @media_works_cache.key?(id)
    @media_works_cache[id]
  end
end
