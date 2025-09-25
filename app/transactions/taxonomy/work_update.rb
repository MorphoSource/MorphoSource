# frozen_string_literal: true
module Morphosource
  module Transactions
    module Taxonomy
      ##
      # Update a Taxonomy work
      class WorkUpdate < Transaction
        DEFAULT_STEPS = ['taxonomy_change_set.set_title',
                        'taxonomy_change_set.set_source',
                        'taxonomy_change_set.set_trusted',
                        'change_set.apply',
                        'work_resource.save_acl'].freeze

        ##
        # @see Hyrax::Transactions::Transaction
        def initialize(container: Container, steps: DEFAULT_STEPS)
          super
        end
      end
    end
  end
end
