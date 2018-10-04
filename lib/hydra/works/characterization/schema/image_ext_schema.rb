module Hydra::Works::Characterization
  class ImageExtSchema < ActiveTriples::Schema

    property :bits_per_sample, predicate: RDF::URI('http://projecthydra.org/ns/mix/bitsPerSample')

  end
end
