module Morphosource
  # validates that parents and children added to the work are valid work types.
  # only needs to check adding children (not adding parent), because a work isn't associated with its parent until it is added as a child to the parent record.
  class ParentChildValidator < ActiveModel::Validator

    def validate(record)
      #invalid_children = []
      #record.works.each do |child|
      #  invalid_children << child.class unless record.valid_child_concerns.include? child.class
      #end

      # delete the child if invalid instead of giving an error (this is a workaround when saving Device
      # in showcase media edit page)
      # todo: might need to investigate why media is found as a child when saving device
      record.works.delete_if do |child|
        unless record.valid_child_concerns.include? child.class
          true # Make sure the if statement returns true, so it gets marked for deletion
        end
      end
      return
      #return if invalid_children.empty?
      #record.errors[:works] << "valid children for #{record.class} do not include #{invalid_children.uniq.join(', ')}."
    end

  end
end
