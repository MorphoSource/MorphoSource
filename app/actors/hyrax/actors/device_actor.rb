# Generated via
#  `rails generate hyrax:work Device`
# @deprecated Device creation/update goes through the device_change_set transaction
#   (see Hyrax::DevicesController), not the actor stack. This class has no live caller;
#   it exists only so that Hyrax's naming-convention-based actor lookup for :device
#   fails loudly instead of silently doing the wrong thing if anything ever reaches it.
module Hyrax
  module Actors
    class DeviceActor < Hyrax::Actors::BaseActor
      # @defunct
      def create(env)
        raise NotImplementedError, "Devices are deprecated, use DeviceResource and Transactions instead."
      end
      alias update create
    end
  end
end
