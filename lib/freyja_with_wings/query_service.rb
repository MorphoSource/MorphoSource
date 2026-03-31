module FreyjaWithWings
  class QueryService < ::Freyja::QueryService
    def postgres_service
      services.find { |service| service.is_a? Valkyrie::Persistence::Postgres::QueryService }
    end

    def wings_service
      services.find { |service| service.is_a? Wings::Valkyrie::QueryService }
    end

    def setup_custom_queries
      super

      postgres_service.custom_queries.register_query_handler(
        Morphosource::CustomQueries::FindFirstAndLastOfModel
      )
      postgres_service.custom_queries.register_query_handler(
        Morphosource::CustomQueries::FindAllByMetadataProperties
      )

      wings_service.custom_queries.register_query_handler(
        Morphosource::CustomQueries::Wings::FindFirstAndLastOfModel
      )
      wings_service.custom_queries.register_query_handler(
        Morphosource::CustomQueries::Wings::FindAllByMetadataProperties
      )
    end
  end
end