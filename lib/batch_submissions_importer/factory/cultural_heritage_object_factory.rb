module BatchSubmissionsImporter
  module Factory
    class CulturalHeritageObjectFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = CulturalHeritageObject

    end
  end
end
