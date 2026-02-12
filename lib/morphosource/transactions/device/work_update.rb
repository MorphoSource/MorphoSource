# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      ##
      # Update a Device work
      class WorkUpdate < Hyrax::Transactions::Transaction
        DEFAULT_STEPS = [
          'device_change_set.set_organization_id',
          'device_change_set.update_organization_access',
          'change_set.apply',
          'work_resource.save_acl',
          'work_resource.update_work_members'
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
