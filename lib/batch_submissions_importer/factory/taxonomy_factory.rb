module BatchSubmissionsImporter
  module Factory
    class TaxonomyFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Taxonomy
      self.valkyrie_klass = TaxonomyResource
    end
  end
end
