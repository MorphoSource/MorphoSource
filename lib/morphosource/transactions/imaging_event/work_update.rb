# frozen_string_literal: true
module Morphosource
  module Transactions
    module ImagingEvent
      ##
      # Updates an ImagingEvent Work from a ChangeSet
      class WorkUpdate < Hyrax::Transactions::Transaction
        DEFAULT_STEPS = [
          'imaging_event_change_set.set_title',
          'imaging_event_change_set.apply_date_filter',
          'imaging_event_change_set.apply_controlled_values',
          'change_set.apply',
          'work_resource.save_acl'
        ].freeze

        ##
        # @see Hyrax::Transactions::Transaction
        def initialize(container: Hyrax::Transactions::Container, steps: DEFAULT_STEPS)
          super
        end
      end
    end
  end
end
