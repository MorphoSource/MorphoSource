class FundCodeMediaAssociation < ApplicationRecord
  belongs_to :fund_code
  before_save :ensure_active_uniqueness

  private 

  def ensure_active_uniqueness
  	if active?
  		FundCodeMediaAssociation.where(media: media).where.not(id: id).update_all(active: false)
  	end	
  end
end
