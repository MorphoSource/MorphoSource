module Morphosource
  module Forms
    module Admin
      class Appearance
        extend ActiveModel::Naming

        attr_reader :attributes
        private :attributes

        SETTINGS = %w[].freeze

        def self.define_methods
          self::SETTINGS.each do |method_name|
            define_method(method_name) do
              block_for(method_name, nil)
            end
          end
        end

        def initialize(attributes = {})
          @attributes = attributes
        end

        def self.model_name
          ActiveModel::Name.new(self, Morphosource, "Morphosource::Admin::#{self.name.demodulize}")
        end

        def to_key
          []
        end

        def persisted?
          true
        end

        def update!
          self.class::SETTINGS.each do |method_name|
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

        def rich_text_for(name, default_value)
          body = block_for(name, default_value)
          ActionText::RichText.new(record_id: name.to_s, record_type: 'Appearance', body: body)
        end
      end
    end
  end
end