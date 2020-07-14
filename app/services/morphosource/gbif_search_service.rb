module Morphosource
  # GBIF Taxonomy Query Service
  class GbifSearchService
    attr_reader :params

    GBIF_HIGHER_TAXONOMY_MAPPING = {
      'kingdom' => 'taxonomy_kingdom',
      'phylum' => 'taxonomy_phylum',
      'class' => 'taxonomy_class',
      'order' => 'taxonomy_order',
      'family' => 'taxonomy_family',
      'genus' => 'taxonomy_genus'
    }

    GBIF_DATASET_KEY = 'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c'

    GBIF_NAME_TERM = 'canonicalName'

    def self.call(params={})
      new(params).call
    end

    # Given a GBIF taxon key, search for the key
    # and create MorphoSource Taxonomy params
    # using the resulting mapped metadata
    def self.taxonomy_params_from_gbif(gbif_key)
      gbif = Morphosource::Gbif.view(gbif_key)
      taxonomy_params = {}

      GBIF_TAXONOMY_MAPPING.each do |key, value|
        if gbif.has_key?(key)
          taxonomy_params[value] ||= gbif[key]
        end
      end

      if gbif.has_key?(GBIF_NAME_TERM)
        name_terms = gbif[GBIF_NAME_TERM].split(' ')
        taxonomy_params['taxonomy_species'] = name_terms[1] if name_terms.length > 1
        taxonomy_params['taxonomy_subspecies'] = name_terms[2] if name_terms.length > 2
      end

      return taxonomy_params
    end

    def initialize(params={})
      @params = params
    end

    def call
      query = assemble_query
      if !query.present?
        return []
      else
        return prepare_results(Morphosource::Gbif.search(query, GBIF_DATASET_KEY))
      end
    end

    private

    def assemble_query
      @params.has_key?('name') ? @params['name'] : ''
    end

    def prepare_results(results)
      synonyms_corrected = false
      new_results = []

      results.each do |taxon|
        if taxon['taxonomicStatus'] == 'SYNONYM' && taxon.has_key?('acceptedKey')
          synonyms_corrected = true
          new_taxon = Morphosource::Gbif.view(taxon['acceptedKey'])
          new_results << prepare_result(new_taxon, true)
        else
          new_results << prepare_result(taxon)
        end
      end

      return {
        synonyms_corrected: synonyms_corrected,
        results: new_results
      }
    end

    def prepare_result(taxon, synonym_correction=false)
      {
        name: taxon['canonicalName'],
        gbif_key: taxon['key'],
        higher_taxonomy: higher_taxon_string(
          higher_taxon_terms.map { |t| taxon.has_key?(t) ? taxon[t] : '' }
        ),
        rank: taxon['rank'],
        synonym_correction: synonym_correction
      }
    end

    def higher_taxon_string(terms)
      s = terms.map.with_index { |t, idx| t.present? ? t : higher_taxon_terms[idx] + ' undefined' }
      s.join(' > ') 
    end

    def higher_taxon_terms
      ['kingdom', 'phylum', 'class', 'order', 'family', 'genus']
    end  
  
  end 
end
