# Returns both users and organization collections
# Restricts data managers to contributor users.
# Restricts list creators to registered users.
module Morphosource
  class DataManagersController < Hyrax::UsersController

    before_action :restrict_to_group, only: [:index]

    def index
      users = search(params[:uq], false)
      organizations = params[:users_only].present? ? [] : search_organizations(params[:uq])
      @data_managers = (organizations + users).sort_by!{|x| x.display_name || '' }
    end

    def blacklight_config
      OrganizationsCatalogController.blacklight_config
    end

    private

    def search_organizations(q)
      blacklight_params = ActionController::Parameters.new( { "search_field"=>"all_fields", "q" => q } )
      search_builder = Morphosource::Catalog::OrganizationCollectionsCatalogSearchBuilder.new(self).with(blacklight_params)
      repository = OrganizationsCatalogController.new.blacklight_config.repository
      repository.search(search_builder.query).documents
    end

    # List creators do not need to be contributor users
    def restrict_to_group
      case request.path
      when "/list-creators"
        params[:group] = "registered"
      else
        params[:group] = "contributor"
      end
    end
  end
end