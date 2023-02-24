# Limited-time URL token for view access to projects/teams & media within
class TemporaryCollectionAccessLink < ApplicationRecord
  belongs_to :user
  has_secure_token

  def self.active_links
    where('expires_at > ?', Time.zone.now)
  end

  def self.document_id_attribute
    :collection_id
  end

  def collection
	  Collection.exists?(collection_id) ? Collection.find(collection_id) : nil
  end

  def active?
    expires_at > Time.now.utc
  end

  # todo: validate expires at isn't in the past when creating
end