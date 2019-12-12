module Morphosource
  module Works
    class Base < ActiveFedora::Base

      class_attribute :work_parents_attributes
      class_attribute :work_requires_files
      class_attribute :valid_parent_concerns

      self.work_requires_files = false

      def self.valid_parent_concerns
        concerns = []
        Morphosource::Works::Base.descendants.each do |model|
          if model.valid_child_concerns.include? self
            concerns << model
          end
        end
        concerns
      end

    end
  end
end
