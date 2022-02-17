module BatchSubmissionsImporter
  module Factory
    class BiologicalSpecimenFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = BiologicalSpecimen

    end
  end
end
