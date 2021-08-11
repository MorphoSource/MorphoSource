module Morphosource
  class ChangeContentOwnerService
    # taken from app/services/hyrax/change_content_depositor_service.rb
    # @param [ActiveFedora::Base] work
    # @param [User] user
    # @param [TrueClass, FalseClass] reset
    def self.call(work, user, reset)
      # user is the new media owner
      work.edit_users += [user]
      if reset == "true" || reset == true
        # remove edit access from old owner and grant read access
        work.edit_users -= [work.user_with_ownership]
        work.read_users += [work.user_with_ownership]
      end
      work.file_sets.each do |f|
        f.edit_users += [user]
        if reset == "true" || reset == true
          # remove edit access from old depositor and grant read access
          f.edit_users -= [work.user_with_ownership]
          f.read_users += [work.user_with_ownership]
        end
        f.save!
      end
      work.apply_owner_metadata(user)
      work.save!
      work
    end
  end
end
