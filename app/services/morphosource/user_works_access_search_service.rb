module Morphosource
  class UserWorksAccessSearchService
    include Blacklight::Configurable
    include Blacklight::SearchHelper

    def self.call(scope:)
      new(scope).call
    end

    def initialize(scope)
      @scope = scope
    end

    def query_builder
      byebug
      Morphosource::UserMediaAccessSearchBuilder.new(@scope)
    end

    def call
      byebug
      repository.search(query_builder.query)
    end

  end
end
