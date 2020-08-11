# frozen_string_literal: true
json.users @users do |user|
  json.id user.id
  json.user_key user.ms_id
  json.text user.email
end
