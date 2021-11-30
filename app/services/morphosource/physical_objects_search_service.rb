module Morphosource
  class PhysicalObjectsSearchService
    include SolrHelper

    attr_reader :solr, :taxonomy_genus, :taxonomy_species, :model, :params, :rows

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(model, params={}, rows=100)
      new(model, params, rows).call
    end

    def initialize(model, params={}, rows=100)
      @solr = solr_service.new
      @model = model
      @taxonomy_genus = params.delete('taxonomy_genus')
      @taxonomy_species = params.delete('taxonomy_species')
      @params = params
      @rows = rows
    end

    def call
      qry = assemble_query
      hits = solr.get_docs(qry, { rows: rows, fq: fq_params })
      # hits = filter_on_taxonomy(hits) if (taxonomy_genus.present? || taxonomy_species.present?)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    private
      # merge specific taxonomy fields as needed, using Solr joins
      def fq_params
        fq = []
        fq << "{!join from=id to=taxonomy_id_ssim}taxonomy_genus_tesim:#{prepare_value(taxonomy_genus)}" if taxonomy_genus.present?
        fq << "{!join from=id to=taxonomy_id_ssim}taxonomy_species_tesim:#{prepare_value(taxonomy_species)}" if taxonomy_species.present?
        return fq
      end

      def model_name
        model.is_a?(Class) ? model.name : model
      end

      def model_clause
        "#{Solrizer.solr_name('has_model', :symbol)}:#{model_name}"
      end
  end
end
