module Hydra::Works::Characterization
  class ImageExtSchema < ActiveTriples::Schema
    property :bits_per_sample, predicate: RDF::Vocab::EXIF.bitsPerSample 
    #property :bits_per_sample, predicate: RDF::URI('http://projecthydra.org/ns/mix/bitsPerSample')
    property :focal_length, predicate: RDF::Vocab::EXIF.focalLength
    property :aperture_value, predicate: RDF::Vocab::EXIF.apertureValue
    property :iso_speed_ratings, predicate: RDF::Vocab::EXIF.isoSpeedRatings
    property :shutter_speed, predicate: RDF::Vocab::EXIF.shutterSpeedValue
  end
end