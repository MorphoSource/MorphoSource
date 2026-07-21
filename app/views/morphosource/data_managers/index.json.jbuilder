# frozen_string_literal: true
json.users @data_managers do |user|
  if user.organization_collection?
    json.id user['id']
    json.user_key user['id']
    json.text user['display_name_ssi']
    json.type 'organization'
  else
    json.id user.id
    json.user_key user.ms_id
    json.text user.name_and_email
    json.type 'user'
  end
end