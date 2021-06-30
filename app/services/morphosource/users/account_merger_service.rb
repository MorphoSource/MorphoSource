# Merges two accounts owned/managed by the same user.
# Transfers download history, cart_item approvals, proxy_rights
module Morphosource
  module Users
    class AccountMergerService

      def self.call(old_email, new_email)
        new(old_email, new_email).call
      end

      def initialize(old_email, new_email)
        @old_user = User.find_by(email: old_email)
        @new_user = User.find_by(email: new_email)
      end

      def call
        transfer_works
        transfer_collections
        transfer_group_permissions
        transfer_proxy_rights
        transfer_cart_items
      end

      def transfer_works
        Hyrax.config.index_related_works = false
        works.each do |work|
          transfer_roles(work)
          transfer_individual_access(work)
          work.save!
          transfer_fileset_access(work)
        end
      end

      def transfer_roles(work)
        if work.depositor == @old_user.ms_id
          work.depositor = @new_user.ms_id
        end
        if work.owner == @old_user.ms_id
          work.owner = @new_user.ms_id
        end
        if work.proxy_depositor == @old_user.ms_id
          work.proxy_depositor = @new_user.ms_id
        end
        if work.on_behalf_of == @old_user.ms_id
          work.on_behalf_of = @new_user.ms_id
        end
        return unless work.media?
        if work.download_reviewer.include? @old_user.ms_id
          work.download_reviewer.delete @old_user.ms_id
          work.download_reviewer << @new_user.ms_id
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
          file_set.depositor = work.depositor
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

      def transfer_collections
        collections.each do |collection|
          collection.depositor = @new_user.ms_id
          collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
          collection.save!
        end
      end

      def transfer_group_permissions
        @old_user.groups.each do |group|
          next if @new_user.groups.include? group
          role = Role.find_by(name: group)
          role.users += [@new_user]
          role.users -= [@old_user]
          role.save!
        end
      end

      def transfer_proxy_rights
        proxy_rights.each do |r|
          if r.grantor_id == @old_user.id
            r.grantor_id = @new_user.id
          end
          if r.grantee_id == @old_user.id
            r.grantee_id = @new_user.id
          end
          r.save
        end
      end

      def transfer_cart_items
        cart_items.each do |i|
          if i.user_id == @old_user.ms_id
            i.user_id = @new_user.ms_id
          end
          if i.action_by == @old_user.ms_id
            i.action_by = @new_user.ms_id
          end
          if i.reviewers.include? @old_user.ms_id
            i.reviewers.delete(@old_user.ms_id)
            i.reviewers << @new_user.ms_id
          end
          i.save
        end
      end

      def works
        ActiveFedora::Base.where("generic_type_sim:Work AND (depositor_ssim:#{@old_user.ms_id} OR edit_access_person_ssim:#{@old_user.ms_id} OR download_access_person_ssim:#{@old_user.ms_id} OR read_access_person_ssim:#{@old_user.ms_id} OR download_reviewer_ssim:#{@old_user.ms_id} OR proxy_depositor_ssim:#{@old_user.ms_id} OR owner_ssim:#{@old_user.ms_id} OR on_behalf_of_ssim:#{@old_user.ms_id})")
      end

      def collections
        ActiveFedora::Base.where("generic_type_sim:Collection AND depositor_ssim:#{@old_user.ms_id}")
      end

      def proxy_rights
        ProxyDepositRights.where(grantor_id: @old_user.id).or(ProxyDepositRights.where(grantee_id: @old_user.id))
      end

      def cart_items
        CartItem.where(user_id: @old_user.ms_id).or(CartItem.where(action_by: @old_user.ms_id)).or(CartItem.where("#{"'" + @old_user.ms_id + "'"} = ANY(reviewers)"))
      end

    end
  end
end
