module Morphosource::UserProfile::UserProfileHelper
  include Morphosource::UserProfile::LocationHelper
  include Morphosource::UserProfile::CheckboxValues

  def number_of_collections_managed(user = current_user)
    byebug
    ::Collection.where(DepositSearchBuilder.depositor_field => user.user_key).count
  rescue RSolr::Error::ConnectionRefused
    'n/a'
  end

end
