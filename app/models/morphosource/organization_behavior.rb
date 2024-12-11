
# Module for methods held in common between organizations and organization collections
module Morphosource
  module OrganizationBehavior

    def agreement_attachment_url
      if attachment('agreement')
        Rails.application.routes.url_helpers.attachment_path(
          id: id,
          field: 'agreement'
        )
      else
        nil
      end
    end

    def enforced_permissions_fields
      permissions_fields.select { |k, v| is_intentionally_blank(k) || v&.first.present? }
    end

    def is_intentionally_blank(field)
      blank_fields = [:license, :rights_holder, :rights_statement]

      blank_fields.include?(field) &&
        ActiveModel::Type::Boolean.new.cast(send("#{field.to_s}_blank")&.first)
    end

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

    def normalize_download_reviewer
      self.download_reviewer = self.download_reviewer.map { |x| x.split(',') }.flatten
    end

  end
end