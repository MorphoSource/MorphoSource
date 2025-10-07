module Morphosource
  module Transactions
    module Taxonomy
      ##
      # Creates a Taxonomy Work from a ChangeSet
      class WorkCreate < Hyrax::Transactions::Transaction
        DEFAULT_STEPS = ['change_set.assign_id',
                        'change_set.set_default_admin_set',
                        'change_set.ensure_admin_set',
                        'change_set.set_user_as_depositor',
                        'taxonomy_change_set.set_title',
                        'taxonomy_change_set.set_source',
                        'taxonomy_change_set.set_trusted',
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
