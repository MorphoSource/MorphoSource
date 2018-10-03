module Morphosource
  # Module to define core metadata properties for
  # Image Capture Event works
  module ImageCaptureEventMetadata
	extend ActiveSupport::Concern

	included do
        
        property :ice_modality, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/captureDevice") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :software, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/software") do |index|
          index.as :stored_searchable, :facetable
        end

        # X-ray CT properties
        property :exposure_time, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#ExposureTime") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :flux_normalization, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/fluxNormalization") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :geometric_calibration, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#PixelSpacingCalibrationType") do |index|
            index.as :stored_searchable, :facetable
        end

        property :shading_correction, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/shadingCorrection") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :filter_material, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#FilterMaterial") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :filter_thickness, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#FilterThicknessMinimum") do |index|
            index.as :stored_searchable, :facetable
        end

        property :frame_averaging, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#ContrastFrameAveraging") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :projections, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#ImagesInAcquisition") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :voltage, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#KVP") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :power, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#GeneratorPower") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :amperage, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#XRayTubeCurrent") do |index|
            index.as :stored_searchable, :facetable
        end
	
        property :surrounding_material, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#ContainerComponentDescription") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :xray_tube_type, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#GeneratorID") do |index|
            index.as :stored_searchable, :facetable
        end
        

        property :target_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/targetType") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :detector_type, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#DetectorDescription") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :detector_configuration, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/detectorConfiguration") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :source_object_distance, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#DistanceSourceToPatient") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :source_detector_distance, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#DistanceSourceToDetector") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :target_material, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#AnodeTargetMaterial") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :rotation_number, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#SpiralPitchFactor") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :phase_contrast, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/phaseContrast") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :optical_magnification, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/opticalMagnification") do |index|
            index.as :stored_searchable, :facetable
        end
        
        # Photogrammetry properties
        property :focal_length_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/focalLengthType") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :background_removal, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/photogrammetryBackgroundRemoval") do |index|
            index.as :stored_searchable, :facetable
        end
        
        # Photogrammetry properties and Photography properties
        property :lens_make, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/exifLensMake") do |index|
            index.as :stored_searchable, :facetable
        end
        
        property :lens_model, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/exifLensModel") do |index|
            index.as :stored_searchable, :facetable
        end

        property :light_source, predicate: ::RDF::URI.new("http://www.w3.org/2003/12/exif/ns#lightSource") do |index|
            index.as :stored_searchable, :facetable
        end
        
	end
  end
end
