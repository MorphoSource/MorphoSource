# Limited-time URL token for view access to media
class TemporaryMediaAccessLink < ApplicationRecord
  belongs_to :user
  has_secure_token
  validate :expires_at_cannot_be_in_the_past

  def self.active_links
    where('expires_at > ?', Time.zone.now)
  end

  def self.document_id_attribute
    :media_id
  end

  def media
    Media.exists?(media_id) ? Media.find(media_id) : nil
  end

  def active?
    expires_at > Time.now.utc
  end

  def expires_at_cannot_be_in_the_past
    if expires_at.present? && expires_at <= Date.today
      errors.add(:expires_at, "can't be in the past")
    end
  end
end