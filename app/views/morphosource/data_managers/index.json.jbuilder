# frozen_string_literal: true
json.users @users do |user|
  byebug
  json.id user.id
  json.user_key user.ms_id
  json.text user.name_and_email
end