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
                            imaging_event_id
                            legacy_media_file_id
                            legacy_media_group_id
                            license
                            map_type
                            media_organization_id
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
                            remote_origin_url
                            remote_manifest_url].freeze

      def media?
        self['has_model_ssim'] == ['Media']
      end

      def all_files_file_size
        self['all_files_file_size_lts']
      end

      def depositor_name
        self['depositor_name_tesim']
      end

      def download_reviewer
        self['download_reviewer_ssim']
      end

      def fileset_visibility
        self[ActiveFedora.index_field_mapper.solr_name('fileset_visibility', :stored_searchable)]
      end

      def fileset_accessibility
        self['fileset_accessibility_ssim']
      end

      def file_sets
        self["file_set_ids_ssim"]&.map{ |id| SolrDocument.find(id) } || []
      end

      def human_readable_media_type
        self[ActiveFedora.index_field_mapper.solr_name('human_readable_media_type', :stored_searchable)].first
      end

      def human_readable_modality
        self['human_readable_modality_tesim']
      end

      def is_remote_backed
        self["is_remote_backed_bsi"]
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

      def physical_object_title
        self['physical_object_title_tesim']
      end

      def physical_object_type
        self[ActiveFedora.index_field_mapper.solr_name('media_physical_object_type', :stored_searchable)]&.first
      end

      def proxy_depositor
        self["proxy_depositor_ssim"]&.first
      end

      def modality
        self[ActiveFedora.index_field_mapper.solr_name('modality', :symbol)]
      end

      def media_organization
        self[ActiveFedora.index_field_mapper.solr_name('media_organization', :stored_searchable)]
      end

      def media_organization_id
        self[ActiveFedora.index_field_mapper.solr_name('media_organization_id', :stored_searchable)]
      end

      def media_physical_object_type
        self[ActiveFedora.index_field_mapper.solr_name('media_physical_object_type', :stored_searchable)]
      end

      def organization_transfer_on_publish
        self["organization_transfer_on_publish_bsi"]
      end

      def publication_status_label
        self["publication_status_ssi"]
      end

      # Add custom column to dashboard works list
      def file_set_visibilities
        self["file_set_visibilities_ssim"]
      end

      def taxonomies_titles
        self["taxonomy_ssim"]
      end

      def agreement_attachment_url
        self['agreement_attachment_url_tesim']
      end
    end
  end
end
