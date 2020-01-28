module Morphosource
  module Works
    class Base < ActiveFedora::Base

      class_attribute :work_parents_attributes
      class_attribute :work_requires_files
      class_attribute :valid_parent_concerns

      self.work_requires_files = false

      def self.valid_parent_concerns
        concerns = Morphosource::Works::Base.descendants
        concerns.each_with_object([]) do |model, parents|
          if model.valid_child_concerns.include? self
            parents << model
          end
        end
      end

      def descendants
        @descendants = ActiveFedora::Base.find(member_ids)
        get_all_children(@descendants)
        @descendants.flatten.uniq
      end

      private

      def get_all_children(objects)
        objects.flatten.each do |object|
          unless object.member_ids.blank?
            children = ActiveFedora::Base.find(object.member_ids)
            @descendants << children
            get_all_children(children)
          end
        end
      end
    end
  end
end
