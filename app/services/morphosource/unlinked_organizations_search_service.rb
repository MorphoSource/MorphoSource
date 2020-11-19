module Morphosource
  class UnlinkedOrganizationsSearchService

    def self.call(params={})
      new(params).call
    end

    def initialize(params={})
      @query = params[:uq]
    end

    def call
      search_orgs
    end

    private

      def search_orgs
        qry = "title_tesim:#{@query}* AND has_model_ssim:Organization NOT team_id_tesim:[* TO *]"
        search_solr(qry)
      end

      def search_solr(qry)
        ActiveFedora::SolrService.query(qry, omitHeader: true, rows: 999999)
      end
  end
end
