# frozen_string_literal: true
module Morphosource
  module Transactions
    module Taxonomy
      module Steps
        ##
        # A step that sets the trusted attribute for a `ValkyrieChangeSet` for a taxonomy work.
        class SetTrusted
          include Dry::Monads[:result]

          ##
          # @param [#trusted=] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:no_trusted, obj] unless obj.respond_to?(:trusted=)

            obj.trusted = ["No"] if !obj.trusted&.first.present?

            Success(obj)
          end
        end
      end
    end
  end
end
