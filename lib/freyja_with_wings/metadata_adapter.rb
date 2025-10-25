# frozen_string_literal: true

# Metadata adapter based on Freyja but using Wings for some work types
# Allows hybrid approach with some Valkyrie resources alongside some AF works
module FreyjaWithWings
  class MetadataAdapter < Freyja::MetadataAdapter
    ##
    # @return [Freyja::Persister]
    def persister
      @persister ||= FreyjaWithWings::Persister.new(adapter: self)
    end
  end
end