# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      module Steps
        ##
        # A step that mints an ARK for a DeviceResource work.
        class MintArk
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::Work] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj, persister: Hyrax.persister)
            return Failure[:no_mint_ark, obj] unless obj.respond_to?(:mint_ark)

            Success(obj.mint_ark(persister: persister))
          rescue StandardError => e
            Failure([:mint_ark_failed, obj, e.message])
          end
        end
      end
    end
  end
end
