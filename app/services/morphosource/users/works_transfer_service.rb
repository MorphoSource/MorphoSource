# Transfers work ownership and request management from one user to another
# Does not transfer download history or permissions that would have been granted by a third user
module Morphosource
  module Users
    class WorksTransferService
      include Morphosource::Users::ServicesSharedBehavior

      def self.call(old_email, new_email)
        new(old_email, new_email).call
      end

      def initialize(old_email, new_email)
        @old_user = User.find_by(email: old_email)
        @new_user = User.find_by(email: new_email)
      end

      def call
        transfer_works
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
        update_download_reviewer(work)
      end

      def transfer_fileset_access(work)
        return unless work.file_sets.present?

        work.file_sets.each do |file_set|
          transfer_individual_access(file_set)
          file_set.save!
        end
      end

      def works
        ActiveFedora::Base.where("generic_type_sim:Work AND (depositor_ssim:#{@old_user.ms_id}  OR download_reviewers_ssim:#{@old_user.ms_id} OR record_download_reviewer_users_ssim:#{@old_user.ms_id} OR owner_ssim:#{@old_user.ms_id})")
      end

    end
  end
end
