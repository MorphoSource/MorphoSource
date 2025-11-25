module Morphosource
  module Transactions
    module Device
      ##
      # Creates a Device Work from a ChangeSet
      class WorkCreate < Hyrax::Transactions::Transaction
        DEFAULT_STEPS = ['device_change_set.assign_id',
                         'change_set.set_default_admin_set',
                         'change_set.ensure_admin_set',
                         'change_set.set_user_as_depositor',
                         'change_set.apply',
                         'work_resource.apply_permission_template',
                         'work_resource.save_acl',
                         'work_resource.add_file_sets',
                         'work_resource.change_depositor',
                         'work_resource.add_to_parent'].freeze

        ##
        # @see Hyrax::Transactions::Transaction
        def initialize(container: Hyrax::Transactions::Container, steps: DEFAULT_STEPS)
          super
        end
      end
    end
  end
end
