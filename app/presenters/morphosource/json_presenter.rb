module Morphosource
  # modified to allow for facet names to come from keys preferentially
  class JsonPresenter < Blacklight::JsonPresenter

    def initialize(response, documents, facets = nil, blacklight_config = nil)
      # Blacklight::JsonPresenter of Blacklight v7.41.0 only takes 2 arguments
      super(response, documents)

      @facets = facets
      @blacklight_config = blacklight_config
    end

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