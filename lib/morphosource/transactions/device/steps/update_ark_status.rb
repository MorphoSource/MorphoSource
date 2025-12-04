# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      module Steps
        ##
        # A step that updates ARK status for a DeviceResource work.
        class UpdateArkStatus
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::Work] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:no_update_ark_status, obj] unless obj.respond_to?(:update_ark_status)

            obj.update_ark_status
            Success(obj)
          rescue StandardError => e
            Failure([:update_ark_status_failed, obj, e.message])
          end
        end
      end
    end
  end
end
