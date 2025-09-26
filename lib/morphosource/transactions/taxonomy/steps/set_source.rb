# frozen_string_literal: true
module Morphosource
  module Transactions
    module Taxonomy
      module Steps
        ##
        # A step that sets the source attribute for a `ValkyrieChangeSet` for a taxonomy work.
        class SetSource
          include Dry::Monads[:result]

          ##
          # @param [#source=] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj)
            return Failure[:no_source, obj] unless obj.respond_to?(:source=)

            obj.source = ["User-Provided"] if !obj.source&.first.present?

            Success(obj)
          end
        end
      end
    end
  end
end
