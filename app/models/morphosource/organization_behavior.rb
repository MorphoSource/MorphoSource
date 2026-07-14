
# OrganizationCollection behavior module
module Morphosource
  module OrganizationBehavior

    # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached, or nil to delete the file
    def agreement_attachment=(file)
      if file.nil?
        # delete attachment
        return unless self.agreement_attachment_url.present?
        file_name = File.basename(self.agreement_attachment_url)
        agreement_uploader.retrieve_from_store!(file_name)
        if agreement_uploader.file.present? && File.exist?(agreement_uploader.file.path)
          Rails.logger.info "Deleting file: #{agreement_uploader.file.path}"
          agreement_uploader.remove!
        else
          Rails.logger.warn "File not found: #{agreement_uploader.file&.path}"
        end
        self.agreement_attachment_url = nil
        self.save
      else
        # add attachment
        extension = File.extname(file.original_filename).downcase
        if agreement_attachment_formats.include?(extension)
          agreement_uploader.store!(file)
          self.agreement_attachment_url = agreement_uploader.url
          self.save
        else
          raise ArgumentError, "Invalid file format: #{extension}"
        end
      end
    end

    def agreement_attachment
      self.agreement_attachment_url
    end

    def agreement_attachment_full_path
      # retrieve and return the full system path to the agreement attachment file
      file_name = File.basename(self.agreement_attachment_url)
      agreement_uploader.retrieve_from_store!(file_name)
      agreement_uploader.file.path
    end

    def agreement_attachment_formats
      @agreement_attachment_formats ||= Morphosource.attachment_formats
    end

    def cultural_heritage_objects
      CulturalHeritageObject.where(organization_id_tesim: id)
    end

    # Media associated with the organization via devices and imaging events
    def device_media
      Media.where(media_device_facility_organization_id_ssim: id)
    end

    def device_specimens
      device_media.map(&:specimens).flatten.uniq { |s| s.id }
    end

    def device_cultural_heritage_objects
      device_media.map(&:cultural_heritage_objects).flatten.uniq { |s| s.id }
    end

    def device_physical_objects
      device_specimens + device_cultural_heritage_objects
    end

    def enforced_permissions_fields
      permissions_fields.select { |k, v| is_intentionally_blank(k) || v&.first.present? }
    end

    def is_intentionally_blank(field)
      blank_fields = [:license, :rights_holder, :rights_statement]

      blank_fields.include?(field) &&
        ActiveModel::Type::Boolean.new.cast(send("#{field.to_s}_blank")&.first)
    end

    def media
      physical_objects.map(&:media).flatten
    end

    def physical_objects
      specimens + cultural_heritage_objects
    end
    alias objects physical_objects

    def permissions_fields
      {
        download_permission: download_permission,
        download_reviewer: download_reviewer,
        rights_holder: rights_holder,
        rights_statement: rights_statement,
        license: license,
        morphosource_use_agreement_type: morphosource_use_agreement_type,
        permits_commercial_use: permits_commercial_use,
        permits_3d_use: permits_3d_use,
        required_archival_of_published_derivatives: required_archival_of_published_derivatives,
        preview_mode: preview_mode,
        agreement_uri: agreement_uri,
        attachment_url: agreement_attachment_url,
        organization_for_attachment: agreement_attachment_url.present? ? id : nil
      }
    end

    def specimens
      BiologicalSpecimen.where(organization_id_tesim: id)
    end

    def normalize_download_reviewer
      self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
    end

    # some countries have multiple continents
    def continent
      return [] unless self.country.present?

      Array(Morphosource::CountriesService.new.continent(self.country.first))
    end

    # Returns ms_ids of the users who should approve download requests for this organization.
    # Org IDs in download_reviewer are resolved recursively to user ms_ids.
    # visited guards against cycles (e.g. Org A → Org B → Org A).
    def media_download_reviewers(visited = Set.new)
      return [] if visited.include?(id)
      visited << id

      if download_reviewer.present?
        user_ids, org_ids = Morphosource::DownloadReviewerResolverService.partition_values(download_reviewer)
        user_ms_ids = User.where(ms_id: user_ids).map(&:ms_id)
        org_ms_ids  = OrganizationCollection.where(id: org_ids)
                                            .flat_map { |org| org.media_download_reviewers(visited) }
        (user_ms_ids + org_ms_ids).uniq
      else
        managers.map(&:ms_id)
      end
    end
  end
end