module Morphosource
  module Forms
    module Admin
      class Modal
        extend ActiveModel::Naming


       MODAL_SETTINGS = %w[sitewide_modal_frequency
                           sitewide_modal_pause_length
                           sitewide_modal_template
                           sitewide_modal_title
                           sitewide_modal_body
                           guilt_trip_template
                           guilt_trip_title
                           guilt_trip_body].freeze

        def initialize(attributes = {})
          @attributes = attributes
        end

        attr_reader :attributes
        private :attributes

        # This allows this object to route to the correct
        def self.model_name
          ActiveModel::Name.new(self, Morphosource, "Morphosource::Admin::Modal")
        end

        def to_key
          []
        end

        def persisted?
          true
        end

        MODAL_SETTINGS.each do |method_name|
          define_method(method_name) do
            block_for(method_name, nil)
          end
        end

        def modal_templates
          files = Dir.glob("app/views/application/modals/*")
          files.map do |file|
            file_name = File.basename(file, ".html.erb").split("_").drop(1).join("_")
          end
        end

        def modal_frequencies
          [["never", 0]] + (1..10).map { |i| ["#{i * 10}%", i / 10.0] }
        end

        def modal_pause_lengths
          ['never', '1 hour', '1 day', '1 week']
        end

        def update!
          MODAL_SETTINGS.each do |method_name|
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