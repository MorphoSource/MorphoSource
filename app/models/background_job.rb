class BackgroundJob < ApplicationRecord

  belongs_to :user, foreign_key: :user_id

  def update_created_objects(params)
    Rails.logger.debug "iN BackgroundJob: saving #{params} to #{created_objects} in main_job #{main_job_id}" 
	# merge the existing params with the passed params
	self.created_objects.merge!(params)
  	self.save
  end

  def clear_created_objects
    Rails.logger.debug "iN BackgroundJob: clearing created_objects... #{created_objects} in main_job #{main_job_id}" 
	self.created_objects = {}
  	self.save
  end

  def update_status(status_str=nil, exceptions=nil)
  	if exceptions.present?
	  Rails.logger.debug "iN BackgroundJob: updating main_job #{main_job_id} with exceptions: #{exceptions} "
	  self.exceptions = exceptions
	  self.save
	end 
  	if status_str.present?
	  Rails.logger.debug "iN BackgroundJob: updating main_job #{main_job_id} with status: #{status_str} " 
byebug
	  self.status = status_str
	  self.save  
	end
  	if exceptions.present? || status_str.present?
  	  self.save
  	end
  end

end
