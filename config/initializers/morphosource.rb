require 'hydra/works/characterization/schema/image_ext_schema.rb'
require 'hydra/works/characterization/schema/dicom_schema.rb'
require 'hydra/works/characterization/schema/mesh_schema.rb'
require 'hydra/works/characterization/schema/zip_contents_schema.rb'

ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
[ 
  Hydra::Works::Characterization::ImageExtSchema,
  Hydra::Works::Characterization::DicomSchema,
  Hydra::Works::Characterization::MeshSchema,
  Hydra::Works::Characterization::ZipContentsSchema
]
