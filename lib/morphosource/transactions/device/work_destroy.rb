# frozen_string_literal: true
module Morphosource
  module Transactions
    module Device
      ##
      # Destroys a DeviceResource work
      class WorkDestroy < Hyrax::Transactions::Transaction
        DEFAULT_STEPS = [
          'work_resource.delete_acl',
          'work_resource.delete'
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
