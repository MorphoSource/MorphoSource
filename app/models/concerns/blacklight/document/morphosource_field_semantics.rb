# SolrDocument Field Semantics based on SolrDocument has_model
module Blacklight
  module Document
    module MorphosourceFieldSemantics
      def field_semantics
        case has_model&.first
        when 'Media'
          media_field_semantics
        when 'BiologicalSpecimen', 'CulturalHeritageObject'
          physical_object_field_semantics
        when 'Collection'
          collection_field_semantics
        else
          other_work_field_semantics
        end
      end

      def collection_field_semantics
        @field_semantics ||= {
          id: 'id',
          project_or_team: 'human_readable_type_tesim',
          title: Solrizer.solr_name('title', :stored_searchable),
          linked_organization: 'linked_organization_tesim',
          description: 'description_tesim',
          creator: 'creator_tesim',
          contributor: 'contributor_tesim',
          location: 'based_near_tesim',
          related_url: 'related_url_tesim',
          visibility: 'visibility_ssi',
          date_uploaded: 'date_uploaded_dtsi',
          date_modified: 'date_modified_dtsi',
        }
      end

      def media_field_semantics
        @field_semantics ||= {
          id: 'id',
          title: Solrizer.solr_name('title', :stored_searchable),
          media_type: Solrizer.solr_name('human_readable_media_type', :stored_searchable),
          modality: Solrizer.solr_name('modality', :symbol),
          device: Solrizer.solr_name('media_device', :stored_searchable),
          device_facility: Solrizer.solr_name('media_device_facility_organization', :stored_searchable),
          media_parent_id: Solrizer.solr_name('media_parent_id', :symbol),
          physical_object_id: Solrizer.solr_name('physical_object_id', :symbol),
          physical_object_title: Solrizer.solr_name('physical_object_title', :stored_searchable),
          physical_object_organization: Solrizer.solr_name('media_organization', :stored_searchable),
          physical_object_type: Solrizer.solr_name('media_physical_object_type', :stored_searchable),
          physical_object_taxonomy: Solrizer.solr_name('taxonomy', :stored_searchable),
          part: Solrizer.solr_name('part', :stored_searchable),
          side: Solrizer.solr_name('side', :stored_searchable),
          creator: Solrizer.solr_name('creator', :stored_searchable),
          short_description: Solrizer.solr_name('short_description', :stored_searchable),
          description: Solrizer.solr_name('description', :stored_searchable),
          ip_holder: Solrizer.solr_name('rights_holder', :stored_searchable),
          copyright_statement: Solrizer.solr_name('rights_statement', :stored_searchable),
          license: Solrizer.solr_name('license', :stored_searchable),
          morphosource_use_agreement_type: Solrizer.solr_name('morphosource_use_agreement_type', :stored_searchable),
          permits_commercial_use: Solrizer.solr_name('permits_commercial_use', :stored_searchable),
          permits_3d_use: Solrizer.solr_name('permits_3d_use', :stored_searchable),
          required_archival_of_published_derivatives: Solrizer.solr_name('required_archival_of_published_derivatives', :stored_searchable),
          funding: Solrizer.solr_name('funding', :stored_searchable),
          publisher: Solrizer.solr_name('publisher', :stored_searchable),
          cite_as: Solrizer.solr_name('cite_as', :stored_searchable),
          ark: Solrizer.solr_name('ark', :stored_searchable),
          doi: Solrizer.solr_name('doi', :stored_searchable),
          external_identifier: Solrizer.solr_name('identifier', :stored_searchable),
          external_media_url: Solrizer.solr_name('related_url', :stored_searchable),
          visibility: Solrizer.solr_name('fileset_accessibility', :stored_searchable),
          in_collections: Solrizer.solr_name('member_of_collections', :symbol),
          date_uploaded: 'date_uploaded_dtsi',
          date_modified: 'date_modified_dtsi',
          legacy_media_group_id: Solrizer.solr_name('legacy_media_group_id', :stored_searchable),
          legacy_media_file_id: Solrizer.solr_name('legacy_media_file_id', :stored_searchable),
          x_pixel_spacing: Solrizer.solr_name('x_spacing', :stored_searchable),
          y_pixel_spacing: Solrizer.solr_name('y_spacing', :stored_searchable),
          z_pixel_spacing: Solrizer.solr_name('z_spacing', :stored_searchable),
          slice_thickness: Solrizer.solr_name('slice_thickness', :stored_searchable),
          unit: Solrizer.solr_name('unit', :stored_searchable),
          number_of_images_in_set: Solrizer.solr_name('number_of_images_in_set', :stored_searchable),
          data_manager: Solrizer.solr_name('user_with_ownership_name', :stored_searchable),
          data_depositor: Solrizer.solr_name('depositor_name', :stored_searchable),
        }
      end

      def physical_object_field_semantics
        @field_semantics ||= {
          id: 'id',
          title: Solrizer.solr_name('title', :stored_searchable),
          organization: Solrizer.solr_name('organization', :stored_searchable),
          institution_code: Solrizer.solr_name('institution_code', :stored_searchable),
          collection_code: Solrizer.solr_name('collection_code', :stored_searchable),
          catalog_number: Solrizer.solr_name('catalog_number', :stored_searchable),
          occurrence_id: Solrizer.solr_name('occurrence_id', :stored_searchable),
          idigbio_uuid: Solrizer.solr_name('idigbio_uuid', :stored_searchable),
          idigbio_recordset_id: Solrizer.solr_name('idigbio_recordset_id', :stored_searchable),
          type: Solrizer.solr_name("human_readable_type", :stored_searchable),
          vouchered: Solrizer.solr_name("vouchered", :stored_searchable),
          taxonomy: Solrizer.solr_name('taxonomy', :stored_searchable),
          sex: Solrizer.solr_name("sex", :stored_searchable),
          creator: Solrizer.solr_name("creator", :stored_searchable),
          date_uploaded: 'date_uploaded_dtsi',
          date_modified: 'date_modified_dtsi'
        }
      end

      def other_work_field_semantics
        @field_semantics ||= {
          id: 'id',
          title: Solrizer.solr_name('title', :stored_searchable),
          date_uploaded: 'date_uploaded_dtsi',
          date_modified: 'date_modified_dtsi'
        }
      end
    end
  end
end
