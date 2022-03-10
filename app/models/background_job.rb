class BackgroundJob < ApplicationRecord

  belongs_to :user, foreign_key: :user_id

  def update_created_objects(params)
    Rails.logger.debug "iN BackgroundJob: saving #{params} to #{created_objects}" 
	# merge the existing params with the passed params
	self.created_objects.merge!(params)


#byebug # the last created child media not saved ?


  	self.save
  end

end
