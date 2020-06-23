class BatchUserImportJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(attributes)
  	if attributes[:contributor] == "true"
  		contributor = true
  	else
  		contributor = false
  	end
  	byebug
  	attributes.delete(:contributor)
    u = User.new(attributes)
    u.validate!
    u.make_contributor if contributor
    u.save!
  end

end