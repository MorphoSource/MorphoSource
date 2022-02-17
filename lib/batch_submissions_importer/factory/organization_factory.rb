module BatchSubmissionsImporter
  module Factory
    class OrganizationFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Organization

    end
  end
end
