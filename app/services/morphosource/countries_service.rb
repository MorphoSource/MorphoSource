# app/services/morphosource/countries_service.rb
module Morphosource
  # Provide select options for the country field in Organization work
  class CountriesService < QaSelectService
    def initialize(_authority_name = nil)
      super('countries')
    end
  end
end
