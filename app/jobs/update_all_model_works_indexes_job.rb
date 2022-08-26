# WARNING: Do not use for any model with >1000 objects
class UpdateAllModelWorksIndexesJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(model)
    model.constantize.find_each do |o|
      Rails.logger.info "Re-indexing begin: #{model} #{o.id}"
      o.update_index 
      Rails.logger.info "Re-indexing done: #{model} #{o.id}"      
    end
  end
end
