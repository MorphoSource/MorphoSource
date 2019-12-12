module Morphosource
  # Takes params in the same format as PhysicalObjectsSearchService
  # and uses them to perform an IDigBio query
  class IDigBioSearchService
    attr_reader :params

    # Mapping from PhysicalObjectsSearchService terms to supported IDigBio index fields
    # see: https://github.com/idigbio/idigbio-search-api/wiki/Index-Fields#record-query-fields
    SEARCH_MAPPING = {
      'taxonomy_genus' => 'genus',
      'taxonomy_species' => 'specificepithet',
      'institution_code' => 'institutioncode'
    }

    def self.call(params={})
      new(params).call
    end

    def initialize(params={})
      @params = params
    end

    def call
      query = assemble_query
      hits = IDigBio.search(query)
    end

    private

    def assemble_query
      SEARCH_MAPPING.each_with_object({}) do |(key, value), return_hash|
        if @params.has_key?(key)
          return_hash[value] = @params[key]
        end
      end
    end
  end
end
