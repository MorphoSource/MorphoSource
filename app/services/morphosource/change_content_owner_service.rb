module Morphosource
  class ChangeContentOwnerService
    # taken from app/services/hyrax/change_content_depositor_service.rb
    # @param [ActiveFedora::Base] work
    # @param [User] user
    # @param [TrueClass, FalseClass] reset
    def self.call(work, user, reset)
      # user is the new media owner
      work.edit_users += [user] unless user_is_organization?(user)
      if reset == "true" || reset == true
        # remove edit access from old owner and grant read access
        work.edit_users -= [work.user_with_ownership]
        work.read_users += [work.user_with_ownership]
      end
      work.file_sets.each do |f|
        f.edit_users += [user] unless user_is_organization?(user)
        if reset == "true" || reset == true
          # remove edit access from old depositor and grant read access
          f.edit_users -= [work.user_with_ownership]
          f.read_users += [work.user_with_ownership]
        end
        f.save!
      end
      if user_is_organization?(user)
        apply_organization_metadata(work, user)
      else
        work.apply_owner_metadata(user)
      end
      work.save!
      work
    end

    def self.user_is_organization?(user)
      @org_user ||= user.is_a?(OrganizationCollection)
    end

    def self.apply_organization_metadata(work, organization)
      work.owner = organization.id
      # byebug
      # work.download_reviewer = organization['download_reviewer_ssim']
    end
  end
end
