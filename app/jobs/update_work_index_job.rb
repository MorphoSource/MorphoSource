class UpdateWorkIndexJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.reindex_queue_name

  def perform(model)
    model.constantize.find_each do |o|
      Rails.logger.info "Re-indexing begin: #{model} #{o.id}"
      o.update_index 
      Rails.logger.info "Re-indexing done: #{model} #{o.id}"      
    end
  end
end
