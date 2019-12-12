module Ms1to2
  module Models
    class BiologicalSpecimen < BaseObject
      def mappings
        {
          :catalog_number => :catalog_number,
          :collection_code => :collection_code,
          :institution_code => :institution_code,
          :collected_on => :date_created,
          :url => :related_url,
          :collector => :creator,
          :description => :description,
          :locality_easting_coordinate => :latitude,
          :locality_northing_coordinate => :longitude,
          :absolute_age => :numeric_time,
          :locality_description => :original_location,
          :relative_age => :periodic_time,
          :recordset => :idigbio_recordset_id, 
          :uuid => :idigbio_uuid,
          :occurrence_id => :occurrence_id,
          :type => :is_type_specimen,
          :sex => :sex,
          :reference_source => :vouchered,
          :created_on => :date_uploaded
        }
      end

      def control_vocab_mappings
        {
          :type => {
            '0' => 'Yes',
            '1' => 'No'
          },
          :sex => {
            'F' => 'Female',
            'M' => 'Male'
          },
          :reference_source => {
            '0' => 'Yes',
            '1' => 'No'
          }
        }
      end

      def expected_special_fields
        [:depositor, :parent_id, :collection_id]
      end
    end
  end
end 