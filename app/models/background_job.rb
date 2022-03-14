class BackgroundJob < ApplicationRecord

  belongs_to :user, foreign_key: :user_id

  def update_created_objects(params)
    Rails.logger.debug "iN BackgroundJob: saving #{params} to #{created_objects}" 
	# merge the existing params with the passed params
	self.created_objects.merge!(params)
  	self.save
  end

  def update_status(status=nil, exceptions=nil)
  	if exceptions.present?
	  Rails.logger.debug "iN BackgroundJob: exceptions: #{exceptions} "
	  self.exceptions = exceptions
	end 
  	if status.present?
	  Rails.logger.debug "iN BackgroundJob: updating job #{main_job_id} with status: #{status} " 
	  self.status = status
	  self.save  
	end
  end

end
