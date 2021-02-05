module Morphosource
  class UserWorksSearchService
    include Blacklight::Configurable
    include Blacklight::SearchHelper

    def self.call(work_type, access, scope)
      new(work_type, access, scope).call
    end

    def initialize(work_type, access, scope)
      @work_type = work_type
      @access = access
      @scope = scope
    end

    def call
      search_solr
    end

    def query_builder
      if @work_type == 'object'
        Morphosource::Users::EditObjectsSearchBuilder.new(@scope)
      elsif @access == 'read'
        Morphosource::Users::ReadMediaSearchBuilder.new(@scope)
      else
        Morphosource::Users::EditMediaSearchBuilder.new(@scope)
      end
    end

    def search_solr
      repository.search(query_builder.query)
    end

  end
end
