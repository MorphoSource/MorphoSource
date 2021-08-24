class SaveWorkJob < ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(object=nil)
  	if object.present?
  		object.save!
  	end
  end
end