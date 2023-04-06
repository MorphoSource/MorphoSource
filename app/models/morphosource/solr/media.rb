module Morphosource
  module Solr
    module Media

      include Morphosource::MediaBehavior

      # media fedora object properties
      MEDIA_PROPERTIES = %w[ark
                            available
                            cite_as
                            doi
                            fileset_accessibility
                            fileset_visibility
                            funding
                            legacy_media_file_id
                            legacy_media_group_id
                            license
                            map_type
                            media_type
                            number_of_images_in_set
                            orientation
                            part
                            rights_statement
                            scale_bar
                            series_type
                            short_description
                            side
                            slice_thickness
                            unit
                            uuid
                            x_spacing
                            y_spacing
                            z_spacing
                            remote_origin_url].freeze

      def download_reviewer
        self['download_reviewer_ssim']
      end

      def fileset_visibility
        self[Solrizer.solr_name('fileset_visibility', :stored_searchable)]
      end

      def fileset_accessibility
        self['fileset_accessibility_ssim']
      end

      def human_readable_media_type
        self[Solrizer.solr_name('human_readable_media_type', :stored_searchable)].first
      end

      def objects
        return nil unless physical_object_ids.present?

        physical_object_ids.each_with_object([]) do |id, objects|
          objects << SolrDocument.find(id)
        end
      end
      alias physical_objects objects

      def physical_object_ids
        self['physical_object_id_ssim']
      end

      def physical_object_type
        self[Solrizer.solr_name('media_physical_object_type', :stored_searchable)]&.first
      end

      def proxy_depositor
        self["proxy_depositor_ssim"]&.first
      end

      def media_modality
        self[Solrizer.solr_name('media_modality', :stored_searchable)]
      end

      def media_organization
        self[Solrizer.solr_name('media_organization', :stored_searchable)]
      end

      def media_organization_id
        self[Solrizer.solr_name('media_organization_id', :stored_searchable)]
      end

      def media_physical_object_type
        self[Solrizer.solr_name('media_physical_object_type', :stored_searchable)]
      end

      # Add custom column to dashboard works list
      def file_set_visibilities
        self["file_set_visibilities_ssim"]
      end
    end
  end
end
