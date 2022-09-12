# Limited-time URL token for view access to media
class TemporaryMediaLink < ApplicationRecord
  belongs_to :user
  has_secure_token
  
  def media
	Media.exists?(media_id) ? Media.find(media_id) : nil
  end
end
