# When searching for data managers, returns both users and organization collections
module Morphosource
  class DataManagersController < Hyrax::UsersController

    def index
      users = search(params[:uq], false)
      organizations = search_organizations(params[:uq])
      @data_managers = organizations + users
    end

    private

      def search_organizations(q)
        repository = OrganizationsCatalogController.new.repository
        repository.search(search_params(q)).documents
      end

      def search_params(q)
        params = {}
        # params[:qt] = "search"
        params[:user_query] = q
        params[:fq] = ["", "{!terms f=has_model_ssim}OrganizationCollection"]
        params[:sort] = "score desc"
        params[:q] = "{!lucene}_query_:\"{!dismax v=$user_query}\""
        params[:defType] = "lucene"
        params[:qf] = "title_tesim institution_name_tesim"
        params[:pf] = "title_tesim"
        # params[:wt] = "json"
        params
      end

      # config.default_solr_params = {
      #   qt: "search",
      #   rows: 10,
      #   qf: "id title_tesim description_tesim creator_tesim keyword_tesim physical_object_title_tesim taxonomy_tesim"
      # }
  end
end