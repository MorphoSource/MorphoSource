module Morphosource
  class ChangeContentOwnerService
    # taken from app/services/hyrax/change_content_depositor_service.rb
    # @param [ActiveFedora::Base] work
    # @param [User] user
    # @param [TrueClass, FalseClass] reset
    def self.call(work, user, reset)
      @work = work
      @user = user
      @reset = ActiveModel::Type::Boolean.new.cast(reset)
      update_new_owner_access
    end

    def self.update_new_owner_access
      update_old_owner_access(@work)
      @work.file_sets.each do |f|
        update_old_owner_access(f)
        f.save!
      end
      # assigns either user.ms_id or organization_collection.id
      @work.owner = @user.try(:user_key) || @user.id
      @work.save!
      @work
    end

    # work here will be @work or a file set
    def self.update_old_owner_access(work)
      work.edit_users += [@user] if @user.is_a?(User)
      return unless @reset

      work.edit_users -= [@work.user_with_ownership]
      work.read_users += [@work.user_with_ownership]
    end
  end
end
