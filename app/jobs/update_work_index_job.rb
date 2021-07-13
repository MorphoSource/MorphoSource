class UpdateWorkIndexJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(model, object=nil)
  	if object.present?
  		object.update_index
  	else
	    model.constantize.find_each do |o|
	      Rails.logger.info "Re-indexing begin: #{model} #{o.id}"
	      o.update_index 
	      Rails.logger.info "Re-indexing done: #{model} #{o.id}"      
	    end
	  end
  end
end
