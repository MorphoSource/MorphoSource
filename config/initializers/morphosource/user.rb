# frozen_string_literal: true

Hyrax::User.module_eval do
  # override to use email as fallback instead of user_key
  # use display_name if not nil or empty string
  def name
    display_name.blank? ? email : display_name
  end
end
