# Retrieves all media a user has been granted read access to through a role (collection members group)
module Morphosource
  module Users
    class ReadMediaSearchBuilder < Hyrax::WorksSearchBuilder

      self.default_processor_chain += [:apply_read_grants_filters]

      def models
        [Media]
      end

      def discovery_permissions
        ['read','download']
      end

      private

        def read_grants_filters
          filters = assemble_query(view_groups_params)
          filters += assemble_query(download_groups_params)
        end

        def apply_read_grants_filters(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << read_grants_filters.reject(&:blank?).join(' OR ')
        end

        # Grant access based on user id & group
        # @return [Array{Array{String}}]
        # override Hyrax to apply filters to admins
        def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
          solr_access_filters_logic.map { |method| send(method, permission_types, ability).reject(&:blank?) }.reject(&:empty?)
        end

        def assemble_query(params)
          query_clauses = param_clauses(params)
          query_clauses.join(' OR ')
          query_clauses
        end

        def param_clauses(specific_params)
          clauses = []
          specific_params.each do |k,v|
            clauses << "#{k}:#{v}"
          end
          clauses
        end

        def view_groups_params
          Hash[view_groups.collect { |v| ['read_access_group_ssim', v] }]
        end

        def download_groups_params
          Hash[download_groups.collect { |v| ['download_access_group_ssim', v] }]
        end

        def view_groups
          current_ability.user_groups.select{ |group| group.include? 'viewers' }
        end

        def download_groups
          current_ability.user_groups.select{ |group| group.include? 'downloaders' }
        end
    end
  end
end
