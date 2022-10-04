# Updates media work owner field, nothing else
# DO NOT use this to transfer a media to another user! It does not actually affect work access, just the owner field
# Used to remediate some media in Sep-2022 to restore MS1 project user as data manager
class UpdateMediaOwnerSlowJob < Hyrax::ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name
  
    def perform(media_id, new_owner_user_key)
      if Media.exists?(media_id) && User.find_by_user_key(new_owner_user_key).present?
        media = Media.find(media_id)
        media.owner = new_owner_user_key
        media.save!
      end
    end
  end