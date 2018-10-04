require 'hydra/works/characterization/schema/image_ext_schema.rb'

ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
    [ Hydra::Works::Characterization::ImageExtSchema ]
