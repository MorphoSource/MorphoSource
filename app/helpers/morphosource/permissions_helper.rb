# frozen_string_literal: true

module Morphosource
  # Helper for setting an organization's media's default permissions
  module PermissionsHelper

    PUBLICATION_OPTIONS = [
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      "restricted_download",
      "preview_only",
      "hidden", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE]

    MULTI_VALUE = ['license', 'agreement_uri', 'funding', 'publisher']

    SINGLE_VALUE = ['rights_statement', 'terms_of_use', 'permits_commercial_use', 'permits_3d_use', 'cite_as']


    def alert(organization)
      "This value has been suggested by #{organization.title.first}"
    end

    def reviewer_email(f)
      ms_id = f.object.model.download_reviewer.first
      user = User.where(ms_id: ms_id).first
      user ? user.email : ''
    end

    def default_present?(form, field)
      form.model.send(field).reject(&:blank?).present?
    end
  end
end
