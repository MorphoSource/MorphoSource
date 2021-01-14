class UpdateProcessingEventMetadataJob < UpdateWorkMetadataJob
  def work_properties
    [
      :software, :processing_activity, :processing_activity_type, 
      :processing_activity_software, :processing_activity_description, :creator, 
      :description
    ]
  end
end