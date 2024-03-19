# When searching for data managers, returns both users and organization collections
module Morphosource
  class DataManagersController < Hyrax::UsersController

    attr_accessor :user

    def index
      if request.format == :html
        authorize! :index, ::User
      end
      users = search(params[:uq], false)
      organizations = search_organizations(params[:uq])
      @data_managers = (organizations + users).sort_by!{|x| x.display_name || '' }
      @users = paginate(@data_managers) # paginate the results for display
    end

    def blacklight_config
      OrganizationsCatalogController.blacklight_config
    end

    private

      def search_organizations(q)
        blacklight_params = ActionController::Parameters.new( { "search_field"=>"all_fields", "q" => q } )
        search_builder = Morphosource::Catalog::OrganizationCollectionsCatalogSearchBuilder.new(self).with(blacklight_params)
        repository = OrganizationsCatalogController.new.repository
        repository.search(search_builder.query).documents
      end

      def paginate(results_array, rows: 1000)
        return if results_array.nil?

        total_pages = (results_array.size.to_f / rows.to_f).ceil
        page = request.params[:page].nil? ? 1 : request.params[:page].to_i
        current_page = page > total_pages ? total_pages : page
        Kaminari.paginate_array(results_array, total_count: results_array.size).page(current_page).per(rows)
      end
  end
end