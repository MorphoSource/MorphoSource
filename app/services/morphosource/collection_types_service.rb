module Morphosource
  class CollectionTypesService

    class << self

      # @return [Integer] collection type ID for project 
      def project_collection_type_id
        Hyrax::CollectionType.find_by(machine_id: 'project').to_global_id.to_s.split('/').last.to_i
      end

      # @return [Integer] collection type ID for team
      def team_collection_type_id
        Hyrax::CollectionType.find_by(machine_id: 'team').to_global_id.to_s.split('/').last.to_i
      end

      # retrieve collection type id, given the collection type name
      # @param [String] collection_type_name
      # @return [Integer] collection type ID
      def collection_type_id_by_name(collection_type_name)
        collection_type_id_by_machine_name(collection_type_name.gsub(' ', '_'))
      end
  
      # retrieve collection type id, given the collection type machine name
      # @param [String] machine_name
      # @return [Integer] collection type ID 
      def collection_type_id_by_machine_name(machine_name)
        Hyrax::CollectionType.find_by(machine_id: machine_name).to_global_id.to_s.split('/').last.to_i
      end

    end
  end
end
