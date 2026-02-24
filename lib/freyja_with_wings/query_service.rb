module FreyjaWithWings
  class QueryService < ::Freyja::QueryService
    def postgres_service
      services.find { |service| service.is_a? Valkyrie::Persistence::Postgres::QueryService }
    end

    def wings_service
      services.find { |service| service.is_a? Wings::Valkyrie::QueryService }
    end
  end
end