# Retrieves all media a user can edit or has been granted read access to through a role (collection members group)
module Morphosource
  module Users
    class MyMediaSearchBuilder < Hyrax::WorksSearchBuilder

      include Hyrax::My::SearchBuilderBehavior

      self.default_processor_chain += [:apply_read_edit_filters]

      def models
        [Media]
      end

      private

        def read_grants_filters
          filters = []
          filters += read_groups_params
          filters += download_groups_params
          filters += edit_groups_params
          filters += edit_user_params
        end

        def apply_read_edit_filters(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << read_grants_filters.reject(&:blank?).join(' OR ')
        end

        def read_groups_params
          ["({!terms f=read_access_group_ssim}#{read_groups.join(',')})"]
        end

        def download_groups_params
          return [] if download_groups.empty?
          ["({!terms f=download_access_group_ssim}#{download_groups.join(',')})"]
        end

        def edit_groups_params
          ["({!terms f=edit_access_group_ssim}#{current_ability.user_groups.join(',')})"]
        end

        def edit_user_params
          ["({!terms f=edit_access_person_ssim}#{current_ability.current_user.ms_id})"]
        end

        def read_groups
          view_groups = current_ability.user_groups - ["public", "registered"]
          view_groups.empty? ? nil_group : view_groups
        end

        def download_groups
          current_ability.user_groups.select{ |group| group.include? 'downloaders' }
        end

        # if both read_groups and download_groups are empty, this makes sure that the search returns 0
        def nil_group
          ['nil_viewers']
        end

    end
  end
end
