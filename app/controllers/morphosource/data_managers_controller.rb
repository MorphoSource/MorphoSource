
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
        {"qt"=>"search", "user_query"=> q, "fq"=>["", "{!terms f=has_model_ssim}OrganizationCollection"], "sort"=>"score desc", "q"=>"{!lucene}_query_:\"{!dismax v=$user_query}\"", "defType"=>"lucene", "qf"=>"title_tesim institution_name_tesim", "pf"=>"title_tesim",  "wt"=>"json"}
      end
  end
end