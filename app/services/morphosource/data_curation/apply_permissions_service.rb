module Morphosource
  module DataCuration
    class ApplyPermissionsService

      def self.call(media_id: nil, update_hierarchy: false)
        new(media_id: media_id, update_hierarchy: update_hierarchy).call
      end

      def initialize(media_id: nil, update_hierarchy: false)
        @media_ids = Array(media_id)
        @update_hierarchy = update_hierarchy
      end

      def call
        raise "Service requires media_id" if @media_ids.empty?
        @media_ids.each do |id|
          Morphosource::ApplyPermissionsJob.perform_later(media_id: id, update_hierarchy: @update_hierarchy)
        end
      end
    end
  end
end