
# Module for methods held in common between organizations and organization collections
module Morphosource
  module OrganizationBehavior

    # todo: agreement_attachment_url is now an attribute returning a path 
    # instead of a method returning a link
    # remove this method later after all references are updated    
    #
    #def agreement_attachment_url
    #  if attachment('agreement')
    #    Rails.application.routes.url_helpers.attachment_path(
    #      id: id,
    #      field: 'agreement'
    #    )
    #  else
    #    nil
    #  end
    #end

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
        organization_for_attachment: attachment('agreement') ? id : nil
      }
    end

    def specimens
      BiologicalSpecimen.where(organization_id_tesim: id)
    end

    def normalize_download_reviewer
      self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
    end
  end
end