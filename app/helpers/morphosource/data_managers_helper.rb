# helper methods for users and organization collections that manage media
module Morphosource
  module DataManagersHelper
    include ActionView::Helpers::UrlHelper

    def data_manager_display(key)
      # Find users by user_key or organization collections by id
      manager = ::User.find_by_user_key(key) || SolrDocument.where({"id" => key}).first
      return "User or Organization #{key}" if manager.nil?

      manager.display_name.present? ? manager.display_name : ( manager.try(:email) || manager.try(:title)&.first )
    end

    def data_manager_path(user)
      case user
      when User
        hyrax.user_path(user)
      when SolrDocument
        main_app.organization_collection_path(user.id)
      end
    end

    def link_to_receiving_user(receiving_user_id)
      link_to_transfer_participant(receiving_user_id)
    end

    # @param user_id [String] the id of a ProxyDepositRequest's sending_user_id or
    #   receiving_user_id, which may belong to either a User or an OrganizationCollection
    def link_to_transfer_participant(user_id)
      if OrganizationCollection.exists?(user_id)
        organization = SolrDocument.find(user_id)
        link_to organization['title_tesim']&.first, main_app.organization_path(organization)
      else
        link_to User.find(user_id).name, hyrax.user_path(User.find(user_id))
      end
    end
  end
end