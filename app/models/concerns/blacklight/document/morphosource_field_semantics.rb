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
        else
          other_work_field_semantics
        end
      end

      def media_field_semantics
        @field_semantics ||= {
          id: 'id',
          title: Solrizer.solr_name('title', :stored_searchable),
          media_type: Solrizer.solr_name('human_readable_media_type', :stored_searchable),
          modality: Solrizer.solr_name('media_modality', :stored_searchable),
          device_facility: Solrizer.solr_name('media_device_facility_organization', :stored_searchable),
          physical_object_id: Solrizer.solr_name('physical_object_id', :symbol),
          physical_object_title: Solrizer.solr_name('physical_object_title', :stored_searchable),
          physical_object_organization: Solrizer.solr_name('media_organization', :stored_searchable),
          physical_object_type: Solrizer.solr_name('media_physical_object_type', :stored_searchable),
          physical_object_taxonomy: Solrizer.solr_name('taxonomy', :stored_searchable),
          short_description: Solrizer.solr_name('short_description', :stored_searchable),
          description: Solrizer.solr_name('description', :stored_searchable),
          part: Solrizer.solr_name('part', :stored_searchable),
          in_collections: Solrizer.solr_name('member_of_collections', :symbol),
          ark: Solrizer.solr_name('ark', :stored_searchable),
          doi: Solrizer.solr_name('doi', :stored_searchable),
          date_uploaded: 'date_uploaded_dtsi',
          date_modified: 'date_modified_dtsi',
          legacy_media_group_id: Solrizer.solr_name('legacy_media_group_id', :stored_searchable),
          legacy_media_file_id: Solrizer.solr_name('legacy_media_file_id', :stored_searchable)
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
