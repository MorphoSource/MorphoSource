module Morphosource
  module Ability
    extend ActiveSupport::Concern
    include Morphosource::Ability::TemporaryLinkAbilities
    include Morphosource::Ability::OrganizationMemberAbilities

    included do
      include Hyrax::Ability

      attr_accessor :temporary_media_access_link
      attr_accessor :temporary_collection_access_link
    end

    # def proxy_deposit_abilities
    #   if Flipflop.transfer_works?
    #     can :transfer, String do |id|
    #       user_is_data_manager?(id)
    #     end
    #   end

    #   can :create, ProxyDepositRequest if (Flipflop.proxy_deposit? || Flipflop.transfer_works?) && registered_user?

    #   can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    #   can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    #   # a user who sent a proxy deposit request can cancel it if it's pending.
    #   can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending'
    # end

    def contributor?
      user_groups.include? 'contributor'
    end

    def batch_submission_contributor?
      user_groups.include? 'batch_submission_contributor'
    end

    def remote_file_submitter?
      user_groups.include? 'remote_file_submitter'
    end

    # Grant all users with edit or download access permission to download
    def download_groups(id)
      @doc ||= get_doc(id)
      return [] if @doc.nil?
      groups = Array(@doc["download_access_group_ssim"]) + Array(@doc["edit_access_group_ssim"])
      Rails.logger.debug("[CANCAN] download_groups: #{groups.inspect}")
      groups
    end

    # Grant all users with edit or download access permission to download
    def download_users(id)
      @doc ||= get_doc(id)
      return [] if @doc.nil?
      users = Array(@doc["download_access_person_ssim"]) + Array(@doc["edit_access_person_ssim"])
      Rails.logger.debug("[CANCAN] download_users: #{users.inspect}")
      users
    end

    # Anyone can download works with 'open' publication status
    def open_download(id)
      @doc ||= get_doc(id)
      return false if @doc.nil?
      @doc["fileset_accessibility_ssim"] == ['open']
    end

    # override to include download users
    # edit implies read, so read_users is the union of edit and read users
    def read_users(id)
      @doc = get_doc(id)
      return [] if @doc.nil?
      rp = Array(@doc["read_access_person_ssim"]) + Array(@doc["read_access_person_ssim"])
      rp |= edit_users(id)
      rp |= download_users(id)
      Rails.logger.debug("[CANCAN] read_users: #{rp.inspect}")
      rp
    end

    # override to include download groups
    # edit and download imply read, so read_groups is the union of edit, download, and read groups
    def read_groups(id)
      @doc = get_doc(id)
      return [] if @doc.nil?
      rg = Array(@doc["read_access_group_ssim"])
      rg |= edit_groups(id)
      rg |= download_groups(id)
      Rails.logger.debug("[CANCAN] read_groups: #{rg.inspect}")
      rg
    end

    # append a new user group (temporarily)
    def user_groups_append(group)
      if !user_groups.include?(group)
        @user_groups << group
      end
      user_groups
    end

    # append a new user group (temporarily)
    def user_groups_exclude(group)
      if user_groups.include?(group)
        @user_groups.delete(group)
      end
      user_groups
    end

    private

      def download_permissions
        can :download, String do |id|
          test_download(id)
        end

        can :download, ActiveFedora::Base do |obj|
          test_download(obj.id)
        end

        can :download, SolrDocument do |obj|
          cache.put(obj.id, obj)
          test_download(obj.id)
        end
      end

      def test_download(id)
        return false if !current_user.registered?
        return true if open_download(id)

        Rails.logger.debug("[CANCAN] Checking download permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
        group_intersection = user_groups & download_groups(id)
        !group_intersection.empty? || download_users(id).include?(current_user.user_key)
      end

      def get_doc(id)
       ActiveFedora::SolrService.get("id:#{id}", params: {qt: :permissions})["response"]["docs"].first
      end

      # Returns true if the current user is the manager of the specified work
      # Returns true if the current user is a manager of the organization collection that owns the work.
      # @param document_id [String] the id of the document.
      def user_is_data_manager?(document_id)
        document = SolrDocument.find(document_id)
        return true if document.user_with_ownership.first == current_user.user_key

        return true if current_user.groups.include? "#{document['owner_ssim']&.first}_managers"

        false
      end

  end
end

Hyrax::Ability.prepend Morphosource::Ability
