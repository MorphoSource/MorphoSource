# frozen_string_literal: true
module Morphosource
  # @note
  #    Did you encounter an exception similar to the following:
  #
  #    "A copy of Hyrax::Listeners::ObjectLifecycleListener has been removed from the module tree but is still active!"
  #
  #    You may need to register a listener as autoload.  See
  #    ./app/services/hyrax/listeners.rb
  module Listeners
    extend ActiveSupport::Autoload

    autoload :DestroyProxyDepositRequestsListener
    autoload :IndexRelatedWorksListener
    autoload :MintDeviceArkListener
    autoload :UpdateDeviceArkStatusListener
  end
end
