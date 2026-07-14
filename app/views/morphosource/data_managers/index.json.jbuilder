# frozen_string_literal: true
json.users @data_managers do |user|
  if user.organization_collection?
    # download_reviewer fields store org ids prefixed so they can be told apart
    # from user ms_ids; data manager/owner fields keep bare org ids
    org_key = params[:reviewer_field] ? Morphosource::DownloadReviewerResolverService.org_value(user['id']) : user['id']
    json.id org_key
    json.user_key org_key
    json.text user['display_name_ssi']
  else
    json.id user.id
    json.user_key user.ms_id
    json.text user.name_and_email
  end
end