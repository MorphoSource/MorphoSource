# frozen_string_literal: true

module Morphosource
  # Provides select options for collection sharing
  module CollectionRolesHelper
    def ms_access_options
      options_for_select(access_array)
    end

    def list_access_options
      roles = MediaList::DEFAULT_GROUP_ROLES
      roles.each_with_object([]) do |role, options|
        options << [t('.' + role.dup.chop), role]
      end
    end

    def list_edit_access_options(access)
      options = list_access_array.reject { |option| option.include? access }
      options_for_select(options << %w[Remove remove])
    end

    def ms_edit_access_options(access)
      options = access_array.reject { |option| option.include? access }
      options_for_select(options << %w[Remove remove])
    end

    def collection_options
      collections = collections_managed(@current_user)
      collections.select!{|c| c["id"] != @collection.id}
      options_for_select(collections.map { |c| [c["title_tesim"].first, c["id"]] })
    end

    def access_array
      roles = Collection::DEFAULT_GROUP_ROLES
      roles.each_with_object([]) do |role, options|
        options << [t('.' + role.dup.chop), role]
      end
    end

    def list_access_array
      roles = MediaList::DEFAULT_GROUP_ROLES
      roles.each_with_object([]) do |role, options|
        options << [t('.' + role.dup.chop), role]
      end
    end

    def collections_managed(current_user)
      ids = current_user.manager_groups.map{|g| g.chomp("_managers")}
      if ids.present?
        Morphosource::SolrService.new
          .get_docs(nil, fq: ["id:(#{ids.join(' OR ').upcase})"], fl: ["id,title_tesim"]).compact
      else
        return []
      end
    end
  end
end
