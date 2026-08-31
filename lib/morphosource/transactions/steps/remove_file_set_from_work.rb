# frozen_string_literal: true

module Morphosource
  module Transactions
    module Steps
      ##
      # Hyrax's RemoveFileSetFromWork#find_parents raises ActiveFedora::ObjectNotFoundError
      # for parent works not yet registered with Wings::ModelRegistry (e.g. Media, which
      # is not yet migrated to Valkyrie) -- treat that the same as "no Valkyrie-visible
      # parents" rather than failing the whole file_set.destroy transaction.
      class RemoveFileSetFromWork < Hyrax::Transactions::Steps::RemoveFileSetFromWork
        private

        def find_parents(resource:)
          super
        rescue ActiveFedora::ObjectNotFoundError
          []
        end
      end
    end
  end
end
