# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      ##
      # Creates a Device Work from a ChangeSet
      class WorkCreate < Hyrax::Transactions::Transaction
        IGNORED_STEP_ARGS = ['work_resource.add_to_parent', 'work_resource.add_file_sets'].freeze

        DEFAULT_STEPS = ['change_set.assign_id',
                         'device_change_set.set_organization_id',
                         'device_change_set.update_organization_access',
                         'change_set.set_default_admin_set',
                         'change_set.ensure_admin_set',
                         'change_set.set_user_as_depositor',
                         'change_set.apply',
                         'work_resource.apply_permission_template',
                         'work_resource.save_acl',
                         'work_resource.change_depositor'].freeze

        ##
        # @see Hyrax::Transactions::Transaction
        def initialize(container: Hyrax::Transactions::Container, steps: DEFAULT_STEPS)
          super
        end

        ##
        # The parent WorksController behavior may pass legacy step args for
        # parent/file-set handling. This transaction deliberately excludes those
        # no-op for Device, so we ignore them here rather than fail fast.
        def with_step_args(**args)
          super(**args.except(*IGNORED_STEP_ARGS))
        end
      end
    end
  end
end
