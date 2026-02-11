# frozen_string_literal: true

require 'freyja'
require 'freyja_with_wings/persister'
require 'freyja_with_wings/query_service'

# Metadata adapter based on Freyja but using Wings for some work types
# Allows hybrid approach with some Valkyrie resources alongside some AF works
module FreyjaWithWings
  class MetadataAdapter < ::Freyja::MetadataAdapter
    ##
    # @return [FreyjaWithWings::Persister]
    def persister
      @persister ||= FreyjaWithWings::Persister.new(adapter: self)
    end

    ##
    # @return [FreyjaWithWings::QueryService, #services]
    def query_service
      @query_service ||= FreyjaWithWings::QueryService.new(
        Valkyrie::Persistence::Postgres::QueryService.new(adapter: self, resource_factory: resource_factory),
        Valkyrie::MetadataAdapter.adapters[:wings_adapter].query_service
      )
    end
  end
end