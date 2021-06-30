# Transfers work ownership and request management from one user to another
# Does not transfer download history or permissions that would have been granted by a third user
module Morphosource
  module Users
    class WorksTransferService

      def self.call(old_email, new_email)
        new(old_email, new_email).call
      end

      def initialize(old_email, new_email)
        @old_user = User.find_by(email: old_email)
        @new_user = User.find_by(email: new_email)
      end

      def call
        transfer_works
        transfer_cart_items
      end

      def transfer_works
        Hyrax.config.index_related_works = false
        works.each do |work|
          transfer_roles(work)
        end
      end

      def transfer_roles(work)
        if work.owner == @old_user.ms_id
          work.owner = @new_user.ms_id
          transfer_individual_access(work)
          work.save!
          transfer_fileset_access(work)
        # keep original depositor info, but transfer ownership
        elsif work.depositor == @old_user.ms_id && work.owner.blank?
          work.owner = @new_user.ms_id
          transfer_individual_access(work)
          work.save!
          transfer_fileset_access(work)
        end
        return unless work.media?
        if work.download_reviewer.include? @old_user.ms_id
          work.download_reviewer.delete @old_user.ms_id
          work.download_reviewer << @new_user.ms_id
          work.save!
        end
      end

      def transfer_individual_access(work)
        transfer_edit_access(work)
        transfer_download_access(work)
        transfer_read_access(work)
      end

      def transfer_fileset_access(work)
        return unless work.file_sets.present?

        work.file_sets.each do |file_set|
          transfer_individual_access(file_set)
          file_set.save!
        end
      end

      def transfer_edit_access(work)
        return unless work.edit_users.include? @old_user.ms_id

        work.edit_users += [@new_user]
        work.edit_users -= [@old_user]
      end

      def transfer_download_access(work)
        return unless work.download_users.include? @old_user.ms_id

        work.download_users += [@new_user]
        work.download_users -= [@new_user]
      end

      def transfer_read_access(work)
        return unless work.read_users.include? @old_user.ms_id

        work.read_users += [@new_user]
        work.read_users -= [@old_user]
      end

      def transfer_cart_items
        cart_items.each do |i|
          if i.reviewers.include? @old_user.ms_id
            i.reviewers.delete(@old_user.ms_id)
            i.reviewers << @new_user.ms_id
          end
          i.save
        end
      end

      def works
        ActiveFedora::Base.where("generic_type_sim:Work AND (depositor_ssim:#{@old_user.ms_id}  OR download_reviewer_ssim:#{@old_user.ms_id} OR owner_ssim:#{@old_user.ms_id})")
      end

      def cart_items
        CartItem.where("#{"'" + @old_user.ms_id + "'"} = ANY(reviewers)")
      end

    end
  end
end
