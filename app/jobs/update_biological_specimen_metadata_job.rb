class UpdateBiologicalSpecimenMetadataJob < UpdateWorkMetadataJob
  def work_properties
    [
      :organization_id, :catalog_number, :collection_code, :institution_code,
      :latitude, :longitude, :numeric_time, :original_location, :periodic_time, 
      :taxonomy_id, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, 
      :occurrence_id, :sex, :canonical_taxonomy, :creator, :contributor, 
      :description, :publisher, :identifier, :related_url
    ]
  end
end