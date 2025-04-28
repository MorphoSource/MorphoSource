# app/services/morphosource/countries_service.rb
module Morphosource
  # Provide select options for the country field in Organization work
  class CountriesService < QaSelectService
    def initialize(_authority_name = nil)
      super('countries')
    end

    # @raise [KeyError] when no 'term' value is present for the id
    def continent(id, &block)
      authority.find(id).fetch('continent', &block)
    end
  end
end
