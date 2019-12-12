Blacklight::AccessControls::User.module_eval do
  def user_key
    send(:ms_id)
  end
end
