# helper methods for users and organization collections that manage media
module Morphosource
  module DataManagersHelper
    include ActionView::Helpers::UrlHelper

    def data_manager_display(key)
      manager = ::User.find_by(id: key) || SolrDocument.where("id" => key).first
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
      if OrganizationCollection.exists?(receiving_user_id)
        organization = SolrDocument.find(receiving_user_id)
        link_to organization['title_tesim']&.first, main_app.organization_path(organization)
      else
        link_to User.find(receiving_user_id).name, hyrax.user_path(User.find(receiving_user_id))
      end
    end
  end
end