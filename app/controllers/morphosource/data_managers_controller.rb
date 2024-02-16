
module Morphosource
  class DataManagersController < Hyrax::UsersController
    helper TagsHelper

    def index
      # byebug
      # if request.format == :html
      #   authorize! :index, ::User
      #   @groups = Morphosource::Users::Defaults::ROLES
      # end
      # @users = search(params[:uq], false)
      # @users = Morphosource::SolrService.new.search_terms("display_name_ssi", params[:uq])
      byebug
      # @users = Morphosource::SolrService.new.get_docs("display_name_ssi:#{params[:uq]&.dump}")
      @users = search_results(params[:uq])
      # byebug
      # @orgs = Morphosource::SolrService.new.search_terms("display_name_ssi", params[:uq])
      # byebug
      # @users
      # @tags = response["terms"]["keyword_tesim"]
      # response = Morphosource::SolrService.new.search_terms("keyword_tesim", params[:uq])
      # @tags = response["terms"]["keyword_tesim"]
    end

    def show
      # @response = TaggedMediaSearchService.call(scope: self)
      # @documents = @response["response"]["docs"].map{|doc| SolrDocument.new(doc) }
      # @document_count = @response[:response][:numFound]
      # render 'morphosource/tags/show'
    end

    def blacklight_config
      OrganizationsCatalogController.blacklight_config
    end

    private

      def search(query, only_active = true)
        byebug
        if current_user&.admin? && params[:group] && Morphosource::Users::Defaults::ROLES.include?(params[:group])
          users = ::User.all.joins(:roles).where(:roles => { name: params[:group] }).distinct
        else
          users = ::User
        end
        byebug
        clause = query.blank? ? nil : "%" + query.downcase + "%"
        base = users.where(*base_query)
        base = base.where("email like lower(?) OR lower(display_name) like lower(?)", clause, clause) if clause.present?
        base = base.where(active: true) if only_active
        base = base.registered
            .where("#{Hydra.config.user_key_field} not in (?)",
                  [::User.batch_user_key, ::User.audit_user_key])
            .references(:trophies)
            .order(sort_value)
            .page(params[:page] || 1).per(per_page_param)

        return base
      end

      def search_results(q)
        user_params = { "user_query"=> q, "search_field"=>"all_fields", "qt"=> "search", "q"=>"{!lucene}_query_:\"{!dismax v=$user_query}\" _query_:\"{!join from=id to=file_set_ids_ssim}{!dismax v=$user_query}\"", "defType"=>"lucene" }
        byebug
        builder = Morphosource::Catalog::OrganizationsCatalogSearchBuilder.new(self).with(user_params).rows(999999)
        byebug
        repository = OrganizationsCatalogController.new.repository
        response = repository.search(builder)
        byebug
        response.documents
      end
  end
end