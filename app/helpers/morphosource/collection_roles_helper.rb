# frozen_string_literal: true

module Morphosource
  # Provides select options for collection sharing
  module CollectionRolesHelper
    def ms_access_options
      options_for_select(access_array)
    end

    def ms_edit_access_options(access)
      options = access_array.reject { |option| option.include? access }
      options_for_select(options << %w[Remove remove])
    end

    def collection_options
      # puts Benchmark.measure {
        collections =     ActiveFedora::Base.where("has_model_ssim:Collection").accessible_by(current_ability, :edit)
      # }
      # byebug
      collections.delete(@collection)
      # puts Benchmark.measure {
        # options_for_select(collections.map { |c| [c.title.first, c.id] })
        collections.map { |c| [c.title.first, c.id] }
      # }
      # byebug
    end

    def access_array
      roles = Collection::DEFAULT_GROUP_ROLES
      roles.each_with_object([]) do |role, options|
        options << [t('.' + role.dup.chop), role]
      end
    end
  end
end
