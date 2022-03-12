class BackgroundJob < ApplicationRecord

  belongs_to :user, foreign_key: :user_id

  def update_created_objects(params)
    Rails.logger.debug "iN BackgroundJob: saving #{params} to #{created_objects}" 
	# merge the existing params with the passed params
	self.created_objects.merge!(params)
  	self.save
  end

  def update_status(status=nil, exception=nil)
  	if exception.present?
	  Rails.logger.debug "iN BackgroundJob: exception: #{exception} "
	  #todo: update exception here later
	end 
  	if status.present?
	  Rails.logger.debug "iN BackgroundJob: updating job #{job_id} with status: #{status} " 
	  self.status = status
	  self.save  
	end
  end

end
