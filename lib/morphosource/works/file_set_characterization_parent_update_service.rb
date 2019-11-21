module Morphosource
  module Works
    class FileSetCharacterizationParentUpdateService
      def self.run(file_set)
        new(file_set).update_parents
      end

      attr_accessor :file_set, :parents

      def initialize(file_set)
        @file_set = file_set
        @parents = file_set.member_of
      end

      def update_parents
        parents.each do |work|
          update_parent(work)
        end
      end

      def update_parent(work)
        field_map.each do |work_field, file_set_field|
          if file_set.send(file_set_field)&.first
            work.send(work_field.to_s + "=", field_transform[work_field])
          end
        end
        work.save!
      end

      def field_map
        {
          :x_spacing => :pixel_spacing,
          :y_spacing => :pixel_spacing,
          :z_spacing => :spacing_between_slices, # slice thickness and number of images in set
          :unit => :pixel_spacing,
          :slice_thickness => :slice_thickness
        }
      end

      def field_transform
        {
          :x_spacing => [file_set.pixel_spacing&.first.split("\\").last],
          :y_spacing => [file_set.pixel_spacing&.first.split("\\").first],
          :z_spacing => [file_set.spacing_between_slices&.first],
          :unit => ["Mm"],
          :slice_thickness => [file_set.slice_thickness&.first]
        }
      end
    end
  end
end
