module Morphosource
  class ReviewedMediaSearchService
    include SolrHelper

    def self.call(params={})
      new(params).call
    end

    def initialize(params={})
      @params = params
      @ms_id = params[:ms_id]
    end

    def call
      find_media(@ms_id)
    end

    private

      def find_media(ms_id)
        qry = assemble_query({ 'depositor' => ms_id, 'owner' => ms_id, 'download_reviewer' => ms_id })
        media = search_solr(qry)
        media.select{ |m| m.reviewer == ms_id }
      end

      def model_clause
        "#{Solrizer.solr_name('has_model', :symbol)}:Media"
      end

      def search_solr(qry)
        ActiveFedora::SolrService.query(qry, rows: 999999, method: :post)
      end
  end
end
