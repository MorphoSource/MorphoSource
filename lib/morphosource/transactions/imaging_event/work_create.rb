# frozen_string_literal: true
module Morphosource
  module Transactions
    module ImagingEvent
      ##
      # Creates a ImagingEvent Work from a ChangeSet
      class WorkCreate < Hyrax::Transactions::Transaction
        IGNORED_STEP_ARGS = ['work_resource.add_to_parent', 'work_resource.add_file_sets'].freeze

        DEFAULT_STEPS = ['change_set.assign_id',
                        'change_set.set_default_admin_set',
                        'change_set.ensure_admin_set',
                        'change_set.set_user_as_depositor',
                        'imaging_event_change_set.set_title',
                        'imaging_event_change_set.apply_date_filter',
                        'imaging_event_change_set.apply_controlled_values',
                        'change_set.apply',
                        'work_resource.apply_permission_template',
                        'work_resource.save_acl',
                        'work_resource.change_depositor'].freeze

        ##
        # @see Hyrax::Transactions::Transaction
        def initialize(container: Hyrax::Transactions::Container, steps: DEFAULT_STEPS)
          super
        end
      end
    end
  end
end