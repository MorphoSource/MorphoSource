module FreyjaWithWings
  class Persister < Freyja::Persister
    # Generic Valkyrie models that signal we are actually looking at an AF work
    AF_RESOURCES = ["Hyrax::PcdmCollection", "Hyrax::Work", "CollectionResource"]

    # Persists a resource within the database
    #
    # Modified from the upstream to use Wings for AF-only models
    #
    # @param [Valkyrie::Resource] resource
    # @return [Valkyrie::Resource] the persisted/updated resource
    # @raise [Valkyrie::Persistence::StaleObjectError] raised if the resource
    #   was modified in the database between been read into memory and persisted
    # rubocop:disable Lint/UnusedMethodArgument

    def save(resource:, external_resource: false, perform_af_validation: false)
      # If resource is a Valkyrie resource, save it using Wings
      if AF_RESOURCES.include?(resource.model_name)
        wings_persister = Wings::Valkyrie::Persister.new(adapter: Wings::Valkyrie::MetadataAdapter.new)
        wings_persister.save(resource: resource, external_resource: external_resource, perform_af_validation: perform_af_validation)
      else
        super
      end

    end
  end
end