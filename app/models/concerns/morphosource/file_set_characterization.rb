module Morphosource
  module FileSetCharacterization
    extend ActiveSupport::Concern

    included do
      new_characterization_terms = [:crc32]

      self.characterization_terms += new_characterization_terms

      delegate(*new_characterization_terms, to: :characterization_proxy)
    end

    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << Hydra::Works::Characterization::ExtendedSchema
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << Hydra::Works::Characterization::ImageExtSchema
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << Hydra::Works::Characterization::DicomSchema
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << Hydra::Works::Characterization::MeshSchema
    ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas << Hydra::Works::Characterization::ZipContentsSchema
  end
end