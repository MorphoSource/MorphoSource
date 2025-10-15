# frozen_string_literal: true
module Morphosource
  # modified to allow for facet names to come from keys preferentially
  class JsonPresenter < Blacklight::JsonPresenter

    def initialize(response, documents, facets = nil, blacklight_config = nil)
      @response = response
      @documents = documents
      @facets = facets
      @blacklight_config = blacklight_config
    end

    attr_reader :documents, :blacklight_config

    def search_facets_as_json
      @facets.as_json.each do |f|
        facet_config = facet_configuration_for_field(f["name"])
        f.delete "options"
        f["name"] = facet_config.key || f["name"]
        f["label"] = facet_config.label
        f["items"] = f["items"].as_json.each do |i|
          i['label'] ||= i['value']
        end
      end
    end
  end
end