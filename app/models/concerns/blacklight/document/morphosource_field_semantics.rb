# frozen_string_literal: true

# SolrDocument Field Semantics based on SolrDocument has_model
module Blacklight
  module Document
    module MorphosourceFieldSemantics
      def field_semantics
        case has_model&.first
        when 'Media'
          media_field_semantics
        when 'FileSet'
          file_set_field_semantics
        when 'BiologicalSpecimen', 'CulturalHeritageObject'
          physical_object_field_semantics
        when 'Device'
          device_field_semantics
        when 'Collection'
          collection_field_semantics
        else
          other_work_field_semantics
        end
      end

      def collection_field_semantics
        @field_semantics ||= {
          id: 'id',
          project_or_team: "human_readable_type_tesim",
          title: "title_tesim",
          linked_organization: "linked_organization_tesim",
          description: "description_tesim",
          creator: "creator_tesim",
          contributor: "contributor_tesim",
          location: "based_near_tesim",
          related_url: "related_url_tesim",
          visibility: "visibility_ssi",
          ark: "ark_tesim",
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi",
        }
      end

      def media_field_semantics
        @field_semantics ||= {
          id: "id",
          title: "title_tesim",
          media_type: "human_readable_media_type_tesim",
          modality: "modality_ssim",
          device: "media_device_tesim",
          device_facility: "media_device_facility_organization_tesim",
          media_parent_id: "media_parent_id_ssim",
          physical_object_id: "physical_object_id_ssim",
          physical_object_title: "physical_object_title_tesim",
          physical_object_organization: "media_organization_tesim",
          physical_object_type: "media_physical_object_type_tesim",
          physical_object_taxonomy_name: "taxonomy_tesim",
          physical_object_taxonomy_gbif: "external_taxonomy_tesim",
          part: "part_tesim",
          side: "side_tesim",
          creator: "creator_tesim",
          short_description: "short_description_tesim",
          description: "description_tesim",
          ip_holder: "rights_holder_tesim",
          copyright_statement: "rights_statement_tesim",
          license: "license_tesim",
          morphosource_use_agreement_type: "morphosource_use_agreement_type_tesim",
          permits_commercial_use: "permits_commercial_use_tesim",
          permits_3d_use: "permits_3d_use_tesim",
          required_archival_of_published_derivatives: "required_archival_of_published_derivatives_tesim",
          funding: "funding_tesim",
          publisher: "publisher_tesim",
          cite_as: "cite_as_tesim",
          ark: "ark_tesim",
          doi: "doi_tesim",
          external_identifier: "identifier_tesim",
          external_media_url: "related_url_tesim",
          visibility: "fileset_accessibility_tesim",
          in_collections: "member_of_collections_ssim",
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi",
          legacy_media_group_id: "legacy_media_group_id_tesim",
          legacy_media_file_id: "legacy_media_file_id_tesim",
          x_pixel_spacing: "x_spacing_tesim",
          y_pixel_spacing: "y_spacing_tesim",
          z_pixel_spacing: "z_spacing_tesim",
          slice_thickness: "slice_thickness_tesim",
          unit: "unit_tesim",
          number_of_images_in_set: "number_of_images_in_set_tesim",
          data_manager: "user_with_ownership_name_tesim",
          data_depositor: "depositor_name_tesim",
          data_sponsor: "active_fund_code_title_ssim",
          file_thumbnail_url: "thumbnail_path_ss",
          file_size_all: "all_files_file_size_lts",
        }
      end

      def file_set_field_semantics
        @field_semantics ||= {
          file_name: "label_tesim",
          file_size: "file_size_lts",
          mime_type: "mime_type_ssi",
          # mesh fields
          point_count: "point_count_tesim",
          face_count: "face_count_tesim",
          has_uv_space: "has_uv_space_tesim",
          vertex_color: "vertex_color_tesim",
          bounding_box_x: "bounding_box_x_tesim",
          bounding_box_y: "bounding_box_y_tesim",
          bounding_box_z: "bounding_box_z_tesim",
          centroid_x: "centroid_x_tesim",
          centroid_y: "centroid_y_tesim",
          centroid_z: "centroid_z_tesim",
          # image fields
          height: "height_is",
          width: "width_is",
          color_space: "color_space_tesim",
          bits_allocated: "bits_allocated_tesim",
          bits_per_sample: "bits_per_sample_tesim",
          compression: "compression_tesim",
          # dicom fields
          rows: "rows_tesim",
          columns: "columns_tesim",
          # zip archive fields
          contents_accepted_file_count: "contents_accepted_file_count_tesim",
          contents_file_name: "contents_file_name_tesim",
          contents_file_size: "contents_file_size_tesim",
          contents_mime_type: "contents_mime_type_tesim",
          # date fields
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi",
      }
      end

      def physical_object_field_semantics
        @field_semantics ||= {
          id: 'id',
          title: "title_tesim",
          organization: "organization_tesim",
          institution_code: "institution_code_tesim",
          collection_code: "collection_code_tesim",
          catalog_number: "catalog_number_tesim",
          occurrence_id: "occurrence_id_tesim",
          idigbio_uuid: "idigbio_uuid_tesim",
          idigbio_recordset_id: "idigbio_recordset_id_tesim",
          ark: "ark_tesim",
          type: "human_readable_type_tesim",
          vouchered: "vouchered_tesim",
          taxonomy_name: "taxonomy_tesim",
          taxonomy_gbif: "external_taxonomy_tesim",
          sex: "sex_tesim",
          creator: "creator_tesim",
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi"
        }
      end

      def device_field_semantics
        @field_semantics ||= {
          id: "id",
          make: 'creator_tesim',
          model: "title_ssi",
          modalities: 'modality_tesim',
          description: 'description_tesim',
          ark: "ark_tesim",
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi"
        }
      end

      def other_work_field_semantics
        @field_semantics ||= {
          id: "id",
          title: "title_tesim",
          date_uploaded: "date_uploaded_dtsi",
          date_modified: "date_modified_dtsi"
        }
      end
    end
  end
end
