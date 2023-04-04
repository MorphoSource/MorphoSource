class BackgroundJob < ApplicationRecord
  belongs_to :user, foreign_key: :user_id, primary_key: :ms_id

  def update_created_objects(params)
	# merge the existing params with the passed params
	self.created_objects.merge!(params)
  	self.save
    Rails.logger.debug "In BackgroundJob #{job_id}: saving #{self.created_objects}" 
  end

  def clear_created_objects
    Rails.logger.debug "In BackgroundJob #{job_id}: clearing created_objects... #{created_objects}" 
	self.created_objects = {}
  	self.save
  end

  def update_status(status_str=nil, exceptions=nil)
  	if exceptions.present?
	  Rails.logger.debug "In BackgroundJob #{job_id}: updating with exceptions: #{exceptions} "
	  self.exceptions = exceptions
	  self.save
	end 
  	if status_str.present?
	  Rails.logger.debug "In BackgroundJob #{job_id}: updating with status: #{status_str} " 
	  self.status = status_str
	  self.save  
	end
  	if exceptions.present? || status_str.present?
  	  self.save
  	end
  end

  def running?
  	self.status == "queued" || self.status == "working"
  end

  def successful?
    self.status == "completed"
  end

end
