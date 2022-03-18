class BackgroundJob < ApplicationRecord

  belongs_to :user, foreign_key: :user_id

  def update_created_objects(params)
	# merge the existing params with the passed params
	self.created_objects.merge!(params)
  	self.save
    Rails.logger.debug "iN BackgroundJob #{main_job_id}: saving #{self.created_objects}" 
  end

  def clear_created_objects
    Rails.logger.debug "iN BackgroundJob #{main_job_id}: clearing created_objects... #{created_objects}" 
	self.created_objects = {}
  	self.save
  end

  def update_status(status_str=nil, exceptions=nil)
  	if exceptions.present?
	  Rails.logger.debug "iN BackgroundJob #{main_job_id}: updating with exceptions: #{exceptions} "
	  self.exceptions = exceptions
	  self.save
	end 
  	if status_str.present?
	  Rails.logger.debug "iN BackgroundJob #{main_job_id}: updating with status: #{status_str} " 
	  self.status = status_str
	  self.save  
	end
  	if exceptions.present? || status_str.present?
  	  self.save
  	end
  end

  def sync_status
  	# check the status from ActiveJob and update if needed
    job_status = ActiveJob::Status.get(self.main_job_id)
    # todo: might need to update the ActiveJob here if the status is marked "canceled"
    if self.status != "canceled" && self.status != "completed" && job_status.present? && job_status.status.to_s != self.status
	  Rails.logger.debug "iN BackgroundJob #{main_job_id}: syncing status with ActiveJob to #{job_status.status.to_s} "
      update_status(job_status.status.to_s)
    end
  end

end
