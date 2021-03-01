# Retrieves all media a user has been granted read access to through a role (collection members group)
module Morphosource
  module Users
    class ReadMediaSearchBuilder < Hyrax::WorksSearchBuilder

      self.default_processor_chain -= [:add_facet_paging_to_solr, :add_access_controls_to_solr_params]
      self.default_processor_chain += [:apply_read_grants_filters]

      def models
        [Media]
      end

      private

        def read_grants_filters
          filters = []
          filters += read_groups_params
          filters += download_groups_params
        end

        def apply_read_grants_filters(solr_parameters)
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

        def read_groups
          view_groups = current_ability.user_groups.select{ |group| group.include? 'viewers' }
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
