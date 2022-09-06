# Updates media work depositor field, nothing else
class UpdateMediaDepositorSlowJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_slow_queue_name
  
    def perform(media_id, new_depositor_user_key)
      if Media.exists?(media_id) && User.find_by_user_key(new_depositor_user_key).present?
        media = Media.find(media_id)
        media.depositor = new_depositor_user_key
        media.save!
      end
    end
  end