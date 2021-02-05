module Morphosource
  class UserWorksAccessSearchService
    include Blacklight::Configurable
    include Blacklight::SearchHelper

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def query_builder
      Morphosource::UserMediaAccessSearchBuilder.new(@scope)
    end

    # def call
    #   byebug
    #   repository.search(query_builder.query).documents
    # end

    def call
      find_shared_view_media
    end

    def find_shared_view_media
      byebug
      qry = assemble_query(view_groups_params)
      search_solr(qry)
    end

    def assemble_query(params)
      byebug
      query_clauses = param_clauses(params)
      byebug
      query_clauses.join(' OR ')
      # query_clauses + "' AND '" + "{!terms f=has_model_ssim}#{"Media"}"
      query_clauses
    end

    def view_groups_params
      Hash[view_groups.collect { |v| ['read_access_group_ssim', v] }]
    end

    def param_clauses(specific_params)
      clauses = []
      specific_params.each do |k,v|
        clauses << "#{k}:#{v}"
      end
      clauses
    end

    def view_groups
      @user.roles.map{|r| r.name if r.name.include? 'viewers' }
    end

    # def filter_models(solr_parameters)
    #   solr_parameters[:fq] ||= []
    #   solr_parameters[:fq] << "{!terms f=has_model_ssim}#{"Media"}"
    # end


    # def search_solr(qry)
    #   byebug
    #   ActiveFedora::SolrService.query(qry, rows: 999999, method: :post)
    # end

    def search_solr(qry)
      byebug
      # ActiveFedora::SolrService.query(query_builder.merge(q: qry))
      repository.search(query_builder.with(qry).query)
    end

  end
end
