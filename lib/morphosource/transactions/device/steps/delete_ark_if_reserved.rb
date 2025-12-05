# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      module Steps
        ##
        # A step that deletes reserved ARKs for a DeviceResource work.
        class DeleteArkIfReserved
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::Work] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:no_delete_ark_if_reserved, obj] unless obj.respond_to?(:delete_ark_if_reserved, true)

            obj.send(:delete_ark_if_reserved)
            Success(obj)
          rescue StandardError => e
            Failure([:delete_ark_if_reserved_failed, obj, e.message])
          end
        end
      end
    end
  end
end
