module Importer
  module Factory
    class TaxonomyFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Taxonomy

    end
  end
end
