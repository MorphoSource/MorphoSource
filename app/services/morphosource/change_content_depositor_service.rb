module Morphosource
  class ChangeContentDepositorService
    # taken from app/services/hyrax/change_content_depositor_service.rb
    # @param [ActiveFedora::Base] work
    # @param [User] user
    # @param [TrueClass, FalseClass] reset
    def self.call(work, user, reset)
byebug
      work.proxy_depositor = work.depositor
      #work.permissions = [] 
      work.edit_users += [user] 
      if reset == "true" || reset == true
        # remove edit access from old depositor and grant read access
        work.edit_users -= [work.depositor]
        work.read_users += [work.depositor]
      end
      work.apply_depositor_metadata(user)
      work.file_sets.each do |f|
        f.apply_depositor_metadata(user)
        f.save!
      end
      work.save!
      work
    end
  end
end
