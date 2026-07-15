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

    def manager_data(f)
      if f.object.model.id.present? && f.object.model.data_manager&.first.present?
        ms_id = f.object.model.data_manager&.first
        { id: ms_id.to_i, user_key: ms_id, text: (u = User.where(ms_id: ms_id)&.first).present? ? u.name_or_email : '' }
      else
        {}
      end.to_json
    end

    def reviewer_data(f)
      if f.object.model.id.present?
        reviewer_select2_items(f.object.model.download_reviewer, keep_unknown: true)
      else
        [user_select2_item(current_user)]
      end.to_json
    end

    # Select2 items for download_reviewer values (users and org collections).
    # keep_unknown: true renders unresolvable values as-is so they can be seen
    # and removed on edit forms; false drops them
    def reviewer_select2_items(values, keep_unknown: false)
      Array(values).map do |value|
        case (object = Morphosource::DownloadReviewerResolverService.resolve_object(value))
        when User
          user_select2_item(object)
        when OrganizationCollection
          { id: value, user_key: value, text: object.name }
        else
          { id: value, user_key: value, text: value } if keep_unknown
        end
      end.compact
    end

    def user_select2_item(user)
      { id: user.ms_id, user_key: user.ms_id, text: user.email.present? ? user.email : user.name_or_email }
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

    # "Current Organization Managers" checkbox on org collection forms:
    # selecting it stores the org itself as its download_reviewer
    def org_managers_reviewer_value(f)
      Morphosource::DownloadReviewerResolverService.org_value(f.object.model.id)
    end

    def org_managers_reviewer_selected?(f)
      Array(f.object.model.download_reviewer).include?(org_managers_reviewer_value(f))
    end

    # Current managers as select2 items, shown read-only when the checkbox is selected
    def org_managers_data(f)
      f.object.model.managers.map do |manager|
        { id: manager.ms_id, user_key: manager.ms_id, text: manager.name_or_email }
      end.to_json
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
