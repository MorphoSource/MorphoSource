module Morphosource
  module Users
    module ServicesSharedBehavior

      def update_download_reviewer(work)
        if work.download_reviewer.include? @old_user.ms_id
          reviewers = work.download_reviewer.each_with_object([]) { |r,reviewers| reviewers << r }
          reviewers.delete @old_user.ms_id
          unless reviewers.include? @new_user.ms_id
            reviewers << @new_user.ms_id
          end
          work.download_reviewer = reviewers
          work.save!
        end
      end

      def transfer_individual_access(work)
        transfer_edit_access(work)
        transfer_download_access(work)
        transfer_read_access(work)
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

    end
  end
end
