module Morphosource
  module ControlledVocabularies
    module Getty
      class Aat < ActiveTriples::Resource
          include Morphosource::ControlledVocabularies::Getty

          # include ::Hyrax::ControlledVocabularies::ResourceLabelCaching

          class_attribute :label


          self.label = lambda do |item|
            byebug
            # [item['name'], item['adminName1'], item['countryName']].compact.join(', ')

          end

      end
    end
  end
end
