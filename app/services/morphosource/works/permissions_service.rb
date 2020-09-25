module Morphosource
  module Works
    class PermissionsService

      def self.source_ids_for_user(access:, ability:, source_type: nil, exclude_groups: [])
        scope = Hyrax::PermissionTemplateAccess.for_user(ability: ability, access: access, exclude_groups: exclude_groups)
                                        .joins(:permission_template)
        ids = scope.pluck('DISTINCT source_id')
        return ids unless source_type
        filter_source(source_type: source_type, ids: ids)
      end
      private_class_method :source_ids_for_user

      def self.filter_source(source_type:, ids:)
        return [] if ids.empty?
        id_clause = "{!terms f=id}#{ids.join(',')}"
        query = case source_type
                when 'media'
                  "_query_:\"{!raw f=has_model_ssim}Media\""
                end
        query += " AND #{id_clause}"
        ActiveFedora::SolrService.query(query, fl: 'id', rows: ids.count).map { |hit| hit['id'] }
      end
      private_class_method :filter_source

      def self.media_ids_for_view(ability:)
        media_ids_for_user(ability: ability, access:
          [Hyrax::PermissionTemplateAccess::MANAGE,
           Hyrax::PermissionTemplateAccess::VIEW])
      end

      def self.media_ids_for_user(access:, ability:)
        source_ids_for_user(access: access, ability: ability, source_type: 'media')
      end
    end
  end
end
