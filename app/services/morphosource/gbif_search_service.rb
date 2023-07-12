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
      gbif = Morphosource::Gbif.view(gbif_key)[:data]
      if correct_synonym && gbif['taxonomicStatus'] == 'SYNONYM' && gbif.has_key?('acceptedKey')
        gbif = Morphosource::Gbif.view(gbif['acceptedKey'])
      end

      return {} if !gbif.present?

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

    # Search for GBIF taxonomy by taxonomy terms
    def self.taxonomy_params_from_gbif_by_terms(terms={})
      name = ''
      if terms['taxonomy_genus'].present? && terms['taxonomy_species'].present? && terms['taxonomy_subspecies'].present?
        name = terms.slice('taxonomy_genus', 'taxonomy_species', 'taxonomy_subspecies').values.join(' ')
      elsif terms['taxonomy_genus'].present? && terms['taxonomy_species'].present?
        name = terms.slice('taxonomy_genus', 'taxonomy_species').values.join(' ')
      else
        higher_terms = ['taxonomy_genus', 'taxonomy_family', 'taxonomy_order', 'taxonomy_class', 'taxonomy_phylum', 'taxonomy_kingdom']
        lowest_high_term = terms.slice(*higher_terms).select { |k, v| v.present? }.values.first
        name = lowest_high_term if lowest_high_term.present?
      end
      if name.present?
        gbif_result = self.call({'name' => name})&.first
      else
        return {}
      end

      return {} if !gbif_result.present?

      # Create params from call result
      gbif_result
        .slice(*(GBIF_HIGHER_TAXONOMY_MAPPING.values.map(&:to_sym) + [:taxonomy_species, :taxonomy_subspecies]))
        .transform_keys(&:to_s)
    end

    def self.occurrence_record_by_id(id)
      result = Morphosource::Gbif.view(id, 'occurrence')
      if result[:status] == :success
        result[:data]
      else
        Rails.logger.error("An error occurred querying the GBIF API: #{result[:message]}")
        {}
      end
    end

    def initialize(params={})
      @params = params
    end

    def call
      query = assemble_query
      if !query.present?
        return []
      else
        return prepare_results(Morphosource::Gbif.search(query, GBIF_DATASET_KEY)[:data])
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
          new_taxon = Morphosource::Gbif.view(taxon['acceptedKey'])[:data]
          new_results << prepare_result(new_taxon, true)
        else
          new_results << prepare_result(taxon)
        end
      end

      return new_results
    end

    def prepare_result(taxon, synonym_correction=false)
      ms_id = ms_taxonomy_id_from_gbif_key(taxon['key'])
      name, species, subspecies = prepare_name(taxon)
      source_info = build_source_info(taxon['key'], synonym_correction, ms_id)
      title = build_title(name, taxon['rank'], source_info)
      id_value = ms_id ? ms_id : 'gbif:' + taxon['key'].to_s
      prepared_taxon = {
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
      GBIF_HIGHER_TAXONOMY_MAPPING.each do |k, v|
        prepared_taxon[v.to_sym] = taxon[k] unless k == 'key'
      end
      prepared_taxon[:taxonomy_species] = species
      prepared_taxon[:taxonomy_subspecies] = subspecies
      return prepared_taxon
    end

    def prepare_name(taxon)
      # Has to be done due to GBIF canonicalName/genus name mismatches
      if taxon['rank'] == 'SPECIES' || taxon['rank'] == 'SUBSPECIES'
        genus = taxon['genus']
        if (taxon[GBIF_NAME_TERM]).present?
          nt = taxon[GBIF_NAME_TERM]&.split(' ') || []
          species = (nt.length > 1) ? nt[1] : nil
          subspecies = (nt.length > 2) ? nt[2] : nil
        else
          species = taxon['species']
          subspecies = nil
        end
        return [genus, species, subspecies].compact.join(' '), species, subspecies
      else
        return taxon[GBIF_NAME_TERM], nil, nil
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
