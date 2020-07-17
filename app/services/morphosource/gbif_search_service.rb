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
      'genus' => 'taxonomy_genus',
      'key' => 'gbif_key'
    }

    GBIF_DATASET_KEY = Morphosource::Gbif.dataset_key

    GBIF_NAME_TERM = 'canonicalName'

    def self.call(params={})
      new(params).call
    end

    # Given a GBIF taxon key, search for the key
    # and create MorphoSource Taxonomy params
    # using the resulting mapped metadata
    def self.taxonomy_params_from_gbif(gbif_key, correct_synonym=false)
      gbif = Morphosource::Gbif.view(gbif_key)
      if correct_synonym && gbif['taxonomicStatus'] == 'SYNONYM' && gbif.has_key?('acceptedKey')
        gbif = Morphosource::Gbif.view(gbif['acceptedKey'])
      end
      
      taxonomy_params = {}

      GBIF_HIGHER_TAXONOMY_MAPPING.each do |key, value|
        if gbif.has_key?(key)
          taxonomy_params[value] ||= gbif[key]
        end
      end

      if gbif.has_key?(GBIF_NAME_TERM)
        name_terms = gbif[GBIF_NAME_TERM].split(' ')
        taxonomy_params['taxonomy_species'] = name_terms[1] if name_terms.length > 1
        taxonomy_params['taxonomy_subspecies'] = name_terms[2] if name_terms.length > 2
      end

      taxonomy_params['gbif_key'] = taxonomy_params['gbif_key'].to_s

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
      new_results = []
      results.each do |taxon|
        if taxon['taxonomicStatus'] == 'SYNONYM' && taxon.has_key?('acceptedKey')
          new_taxon = Morphosource::Gbif.view(taxon['acceptedKey'])
          new_results << prepare_result(new_taxon, true)
        else
          new_results << prepare_result(taxon)
        end
      end

      return new_results
    end

    def prepare_result(taxon, synonym_correction=false)
      ms_id = ms_taxonomy_id_from_gbif_key(taxon['key'])
      name = prepare_name(taxon)
      source_info = build_source_info(taxon['key'], synonym_correction, ms_id)
      title = build_title(name, taxon['rank'], source_info)
      id_value = ms_id ? ms_id : 'gbif:' + taxon['key'].to_s
      {
        id: id_value, 
        label: [title], 
        value: id_value,
        name: name,
        gbif_key: taxon['key'].to_s,
        higher_taxonomy: higher_taxon_string(
          higher_taxon_terms.map { |t| taxon.has_key?(t) ? taxon[t] : '' }
        ),
        rank: taxon['rank'],
        synonym_correction: synonym_correction,
        ms: ms_id,
        source_info: source_info
      }
    end

    def prepare_name(taxon) 
      # Has to be done due to GBIF canonicalName/genus name mismatches
      if taxon['rank'] == 'SPECIES' || taxon['rank'] == 'SUBSPECIES'
        nt = taxon[GBIF_NAME_TERM].split(' ')
        taxon['genus'] + ( nt.length > 1 ? ' ' + nt[1] : '' ) + ( nt.length > 2 ? ' ' + nt[2] : '' )
      else
        taxon[GBIF_NAME_TERM]
      end
    end

    def higher_taxon_string(terms)
      s = terms.map.with_index { |t, idx| t.present? ? t : higher_taxon_terms[idx] + ' undefined' }
      s.join(' > ') 
    end

    def higher_taxon_terms
      ['kingdom', 'phylum', 'class', 'order', 'family', 'genus']
    end  

    def ms_taxonomy_id_from_gbif_key(gbif_key)
      gbif_result = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_key.to_s })
      gbif_result.present? ? gbif_result.first.id : nil
    end

    def build_source_info(gbif_key, synonym_correction, ms)
      source_chunks = [];
      source_chunks << 'GBIF Taxonomy' if gbif_key.present?
      source_chunks << 'Suggested Accepted Taxon' if synonym_correction.presence
      source_chunks << 'In MorphoSource' if ms.present?
      source_chunks.join(' · ')
    end

    def build_title(name, rank=nil, source_info=nil)
      name +
      ( rank.present? ? ' · ' + rank.titleize : '' ) +
      ( source_info.present? ? ' · ' + source_info : '' )
    end
  end 
end
