# When searching for data managers, returns both users and organization collections
module Morphosource
  class DataManagersController < Hyrax::UsersController

    def index
      params[:group] = "contributor" # limit users to those with contributor status
      users = search(params[:uq], false)
      organizations = search_organizations(params[:uq])
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
  end
end