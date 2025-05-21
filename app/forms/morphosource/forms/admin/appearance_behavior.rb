module Morphosource
  module Forms
    module Admin
      module AppearanceBehavior
        extend ActiveModel::Naming

        attr_reader :attributes
        private :attributes

        def initialize(attributes = {})
          @attributes = attributes
        end

        # This allows this object to route to the correct
        def self.model_name
          ActiveModel::Name.new(self, Morphosource, "Morphosource::Admin::#{self.name.demodulize}")
        end

        self.class::SETTINGS.each do |method_name|
          byebug
          define_method(method_name) do
            block_for(method_name, nil)
          end
        end

        def to_key
          []
        end

        def persisted?
          true
        end

        def update!
          byebug
          self::SETTINGS.each do |method_name|
            update_block(method_name, attributes[method_name])
          end
        end

        private

        def block_for(name, default_value)
          block = ContentBlock.find_by(name: name)
          block ? block.value : default_value
        end

        def update_block(name, value)
          ContentBlock.find_or_create_by(name: name).update!(value: value)
        end
      end
    end
  end
end