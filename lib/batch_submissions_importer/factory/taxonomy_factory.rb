module BatchSubmissionsImporter
  module Factory
    # todovalk: update this to work with valkyrie resource
    class TaxonomyFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Taxonomy

    end
  end
end
