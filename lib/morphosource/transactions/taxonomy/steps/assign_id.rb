# frozen_string_literal: true
module Morphosource
  module Transactions
    module Taxonomy
      module Steps
        ##
        # A step that assigns IDs for taxonomy work using MorphoSource ID minter.
        class AssignID
          include Dry::Monads[:result]

          ##
          # @param [Hyrax::ChangeSet] obj
          #
          # @return [Dry::Monads::Result]
          def call(obj) # obj is the form
            if obj.id.blank?
              obj.id = ::Noid::Rails::Service.new.mint
            end
            Success(obj)
          end
        end
      end
    end
  end
end