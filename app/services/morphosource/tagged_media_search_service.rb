module Morphosource
  class TaggedMediaSearchService
    include Blacklight::Configurable
    include Blacklight::SearchContext

    def self.call(scope:)
      new(scope).call
    end

    def initialize(scope)
      @scope = scope
    end

    def query_builder
      Morphosource::TaggedWorksSearchBuilder.new(@scope).rows(999999)
    end

    def call
      blacklight_config.repository.search(query_builder.query)
    end

  end
end
