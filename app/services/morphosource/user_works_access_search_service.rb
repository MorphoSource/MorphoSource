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

    # def query_builder
    #   Morphosource::UserMediaAccessSearchBuilder.new(@scope)
    # end

    # def call
    #   byebug
    #   repository.search(query_builder.query).documents
    # end

    def call
      find_shared_view_media
    end

    def find_shared_view_media
      qry = assemble_query(view_groups_params)
      search_solr(qry)
    end

    def assemble_query(params)
      query_clauses = param_clauses(params)
      query_clauses.join(' OR ')
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

    def search_solr(qry)
      byebug
      ActiveFedora::SolrService.query(qry, rows: 999999, method: :post)
    end

  end
end
