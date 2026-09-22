# frozen_string_literal: true
json.id       @user.id
json.user_key @user.ms_id
json.email    @user.email
json.name     @user.name
json.admin    true if @user.admin?
