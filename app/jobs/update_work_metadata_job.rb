class UpdateWorkMetadataJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.reindex_queue_name

  def perform(work_attributes)
  	if ::ActiveFedora::Base.exists?(work_attributes[:id]&.first)
  		work = ::ActiveFedora::Base.find(work_attributes[:id]&.first)
  		work_properties.each do |p|
        if work_attributes[p].present? && work[p] != work_attributes[p]
          work[p] = work_attributes[p]
        end
  		end
  		work.save!
  	end
  end

  def work_properties # should be customized in inheritors
    []
  end
end