# frozen_string_literal: true
json.users @users do |user|
  json.id user.user_key
  json.text user.email
end
