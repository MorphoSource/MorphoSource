module Morphosource
  module Ability
    extend ActiveSupport::Concern
    included do
      include Hyrax::Ability
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
  end
end

Hyrax::Ability.prepend Morphosource::Ability
