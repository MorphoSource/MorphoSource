module BatchSubmissionsImporter
  module Factory
    class MediaFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = Media

    end
  end
end
