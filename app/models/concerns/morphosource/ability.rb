module Morphosource
  module Ability
    extend ActiveSupport::Concern
    included do
      include Hyrax::Ability

      attr_accessor :temporary_media_access_link
      attr_accessor :temporary_collection_access_link
    end

    def temporary_link_abilities
      can :destroy, TemporaryMediaAccessLink do |link|
        ( current_user.id == link.user_id ) || current_user.admin? || user_is_data_manager?(link.media_id) 
      end

      can :destroy, TemporaryCollectionAccessLink do |link|
        ( current_user.id == link.user_id ) || current_user.admin? || (
          Collection.exists?(id) &&
          Collection.find(id).managers.include?(current_user)
        )
      end

      # Viewing media and file_sets via temporary access link
      can :read, [ActiveFedora::Base, ::SolrDocument] do |obj|
        # For single media temp access link
        if temporary_media_access_link.present?
          Rails.logger.debug("[CANCAN] Checking for individual media temporary access grant")
        
          if obj.file_set?
            obj = obj.is_a?(ActiveFedora::Base) ? obj.member_of&.first : FileSet.find(obj.id).member_of&.first
            return false unless obj.present?
          end

          temporary_media_access_link.active? && temporary_media_access_link.media_id == obj.id
        end

        # For project-wide temp access link
        if temporary_collection_access_link.present?
          Rails.logger.debug("[CANCAN] Checking for collection temporary access grant")

          (obj.team? || obj.project? ) && 
            temporary_collection_access_link.active? && 
            temporary_collection_access_link.collection_id == obj.id
        end
      end

      can :read, String do |id|
        if temporary_media_access_link.present? || temporary_collection_access_link.present?
          obj = ActiveFedora::Base.find(id)
          can? :read, obj
        end
      end
    end

    def proxy_deposit_abilities
      if Flipflop.transfer_works?
        can :transfer, String do |id|
          user_is_data_manager?(id)
        end
      end

      can :create, ProxyDepositRequest if (Flipflop.proxy_deposit? || Flipflop.transfer_works?) && registered_user?

      can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
      can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
      # a user who sent a proxy deposit request can cancel it if it's pending.
      can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending'
    end

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
      # @param document_id [String] the id of the document.
      def user_is_data_manager?(document_id)
        SolrDocument.find(document_id).user_with_ownership.first == current_user.user_key
      end

  end
end

Hyrax::Ability.prepend Morphosource::Ability
