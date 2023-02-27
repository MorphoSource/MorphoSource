# Limited-time URL token for view access to media
class TemporaryMediaAccessLink < ApplicationRecord
  belongs_to :user
  has_secure_token

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

  # todo: validate expires at isn't in the past when creating
end