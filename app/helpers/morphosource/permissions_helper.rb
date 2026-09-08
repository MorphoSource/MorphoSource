# frozen_string_literal: true

module Morphosource
  # Helper for setting an organization's media's default permissions
  module PermissionsHelper

    PUBLICATION_OPTIONS = [
      ["Publish with Open Download", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC],
      ["Publish with Restricted Download", "restricted_download"],
      ["Private", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE]
    ]

    MULTI_VALUE = ['license', 'agreement_uri', 'funding', 'publisher']

    SINGLE_VALUE = ['rights_statement', 'permits_commercial_use', 'permits_3d_use', 'cite_as']


    def alert(organization)
      "This value has been suggested by #{organization&.title&.first}"
    end

    def reviewer_email(f)
      ms_id = f.object.model.record_download_reviewer_users.first
      user = User.where(ms_id: ms_id).first
      user ? user.email : ''
    end

    def manager_data(f)
      if f.object.model.id.present? && f.object.model.data_manager&.first.present?
        ms_id = f.object.model.data_manager&.first
        { id: ms_id.to_i, user_key: ms_id, text: (u = User.where(ms_id: ms_id)&.first).present? ? u.name_or_email : '' }
      else
        {}
      end.to_json
    end

    def reviewer_data(f, field: :record_download_reviewer_users)
      if f.object.model.id.present?
        f.object.model.public_send(field).map do |ms_id|
          { id: ms_id.to_i, user_key: ms_id, text: (u = User.where(ms_id: ms_id)&.first).present? ? u.name_or_email : '' }
        end
      else
        { id: current_user.ms_id.to_i, user_key: current_user.ms_id, text: current_user.name_or_email }
      end.to_json
    end

    def contributor_data(f)
      if f.object.model.id.present?
        f.object.model.contributor.map do |ms_id|
          { id: ms_id.to_i, user_key: ms_id, text: (u = User.where(ms_id: ms_id)&.first).present? ? u.name_or_email : '' }
        end
      else
        { id: current_user.ms_id.to_i, user_key: current_user.ms_id, text: current_user.name_or_email }
      end.to_json
    end

    def creator_data(f)
      if f.object.model.id.present?
        if creator = f.object.model.creator&.first
          { id: creator.to_i, user_key: creator, text: (u = User.where(ms_id: creator)&.first).present? ? u.name_or_email : '' }
        end
      else
        { id: current_user.ms_id.to_i, user_key: current_user.ms_id, text: current_user.name_or_email }
      end.to_json
    end

    def default_present?(form, field)
      form.model.send(field).reject(&:blank?).present?
    end

    def form_model_name(f)
      f.object.model_name.singular
    end

    def download_permission(f)
      case form_model_name(f)
      when 'organization'
        normalized_download_permission(f.object.download_permission)
      when 'organization_collection'
        normalized_download_permission(f.object.download_permission)
      when 'media'
        media_download_permission(f.object)
      end
    end

    def badge_class(f)
      case normalized_download_permission(download_permission(f))
      when 'open'
        'badge badge-success'
      when 'restricted_download'
        'badge badge-info'
      when 'private'
        'badge badge-danger'
      end
    end

    # media method download_permission causing js problems during submission, so putting this here
    def media_download_permission(media)
      case media.publication_status
      when 'open'
        'open'
      when 'restricted'
        'restricted_download'
      when 'private'
        'private'
      end
    end

    def human_readable_publication_status(f)
      case normalized_download_permission(download_permission(f))
      when 'open'
        'Open Download'
      when 'restricted_download'
        'Restricted Download'
      when 'private'
        'Private'
      end
    end

    def download_permission_input(f)
      case form_model_name(f)
      when 'organization'
        "<input type='hidden' id= 'organization_download_permission' name='organization[download_permission]' class='download-permission' value= #{download_permission(f)} >".html_safe
      when 'organization_collection'
        "<input type='hidden' id= 'organization_collection_download_permission' name='organization_collection[download_permission]' class='download-permission' value= #{download_permission(f)} >".html_safe
      when 'media'
        "<input type='hidden' id= 'media_download_permission' name='media[visibility]' class='download-permission' value= #{download_permission(f)} >".html_safe
      end
    end

    private

    def normalized_download_permission(value)
      value = Array(value).first
      value == 'restricted' ? 'private' : value
    end
  end
end
