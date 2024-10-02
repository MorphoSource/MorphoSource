# Modified from hydra-works 2.1.0 FitsDocument to add more fields and reorganize fields into groups
module Hydra::Works::Characterization
  class FitsDocument
    attr_accessor :ng_xml

    PROXIED_TERMS = %i(
      fits_version format_label file_mime_type exif_tool_version 
      
      file_size date_modified filename original_checksum date_created rights_basis
      copyright_basis copyright_note well_formed valid filestatus_message
      
      file_title file_author file_language page_count word_count
      character_count paragraph_count line_count table_count graphics_count

      modality spacing_between_slices secondary_capture_device_manufacturer 
      secondary_capture_device_software_vers file_type_extension image_type
      study_date series_date content_date study_time series_time content_time
      accession_number instance_number image_position_patient image_orientation_patient
      samples_per_pixel photometric_interpretation rows columns dicom_height dicom_width
      pixel_spacing slice_thickness bits_allocated bits_stored high_bit 
      pixel_representation window_center window_width rescale_intercept rescale_slope
      window_center_and_width_explanation exposure_time pixel_spacing_calibration_description
      pixel_spacing_calibration_type contrast_frame_averaging images_in_acquisition KVP
      generator_power x_ray_tube_current container_description generator_id
      detector_description distance_source_to_patient distance_source_to_detector
      anode_target_material spiral_pitch_factor number_of_series_related_instances

      byte_order compression height width color_space profile_name profile_version
      orientation color_map image_producer capture_device scanning_software
      exif_version gps_timestamp latitude longitude bits_per_sample focal_length
      iso_speed_ratings aperture_value shutter_speed
      
      video_height video_width video_duration video_bit_rate video_sample_rate
      video_audio_sample_rate frame_rate video_track_height video_track_width
      track_frame_rate aspect_ratio

      audio_duration bit_depth audio_bit_rate audio_sample_rate channels data_format offset
       
      character_set markup_basis markup_language   
    ).freeze

    def proxied_term_hash
      PROXIED_TERMS.map { |t| [t, send(t)] }.to_h
    end

    def self.terminology
      struct = Struct.new(:proxied_term).new
      terminology = Struct.new(:terms)
      terminology.new(PROXIED_TERMS.map { |t| [t, struct] }.to_h)
    end

    #  t.fits_version(proxy: [:fits, :fits_v])
    def fits_version
      ng_xml.css("fits").map { |n| n['version'].text }
    end

    # t.format_label(proxy: [:identification, :identity, :format_label])
    def format_label
      ng_xml.css("fits > identification > identity").map { |n| n['format'] }
    end

    # Can't use .mime_type because it's already defined for this document so method missing won't work.
    # t.file_mime_type(proxy: [:identification, :identity, :mime_type])
    def file_mime_type
      # Sometimes, FITS reports the mimetype attribute as a comma-separated string.
      # All terms are arrays and, in this case, there is only one element, so scan the first.
      ng_xml.css("fits > identification > identity").map { |n| n['mimetype'].split(',').first }
    end

    # t.exif_tool_version(proxy: [:identification, :identity, :tool, :exif_tool_version])
    def exif_tool_version
      ng_xml.css("fits > identification > identity > tool[toolname='Exiftool']").map { |n| n['toolversion'] }
    end

    # @!group file

    # t.file_size(proxy: [:fileinfo, :file_size])
    def file_size
      ng_xml.css("fits > fileinfo > size").map(&:text)
    end

    # t.date_modified(proxy: [:fileinfo, :last_modified])
    def date_modified
      ng_xml.css("fits > fileinfo > lastmodified[toolname='Exiftool']").map(&:text)
    end

    

    # t.date_created(proxy: [:fileinfo, :date_created])
    def date_created
      ng_xml.css("fits > fileinfo > created[toolname='Exiftool']").map(&:text)
    end

    # t.rights_basis(proxy: [:fileinfo, :rights_basis])
    def rights_basis
      ng_xml.css("fits > fileinfo > rightsBasis").map(&:text)
    end

    # t.copyright_basis(proxy: [:fileinfo, :copyright_basis])
    def copyright_basis
      ng_xml.css("fits > fileinfo > copyrightBasis").map(&:text)
    end

    # t.copyright_basis(proxy: [:fileinfo, :copyright_note])
    def copyright_note
      ng_xml.css("fits > fileinfo > copyrightNote").map(&:text)
    end

    # t.well_formed(proxy: [:filestatus, :well_formed])
    def well_formed
      ng_xml.css("fits > filestatus > well-formed").map(&:text)
    end

    # t.valid(proxy: [:filestatus, :valid])
    def valid
      ng_xml.css("fits > filestatus > valid").map(&:text)
    end

    # t.filestatus_message(proxy: [:filestatus, :status_message])
    def filestatus_message
      ng_xml.css("fits > filestatus > message").map(&:text)
    end

    # @!endgroup
    # @!group document

    # t.file_title(proxy: [:metadata, :document, :file_title])
    def file_title
      ng_xml.css("fits > metadata > document > title").map(&:text)
    end

    # t.file_author(proxy: [:metadata, :document, :file_author])
    def file_author
      ng_xml.css("fits > metadata > document > author").map(&:text)
    end

    # t.file_language(proxy: [:metadata, :document, :file_language])
    def file_language
      ng_xml.css("fits > metadata > document > language").map(&:text)
    end

    # t.page_count(proxy: [:metadata, :document, :page_count])
    def page_count
      ng_xml.css("fits > metadata > document > pageCount").map(&:text)
    end

    # t.word_count(proxy: [:metadata, :document, :word_count])
    def word_count
      ng_xml.css("fits > metadata > document > wordCount").map(&:text)
    end

    # t.character_count(proxy: [:metadata, :document, :character_count])
    def character_count
      ng_xml.css("fits > metadata > document > characterCount").map(&:text)
    end

    # t.paragraph_count(proxy: [:metadata, :document, :paragraph_count])
    def paragraph_count
      ng_xml.css("fits > metadata > document > paragraphCount").map(&:text)
    end

    # t.line_count(proxy: [:metadata, :document, :line_count])
    def line_count
      ng_xml.css("fits > metadata > document > lineCount").map(&:text)
    end

    # t.table_count(proxy: [:metadata, :document, :table_count])
    def table_count
      ng_xml.css("fits > metadata > document > tableCount").map(&:text)
    end

    # t.graphics_count(proxy: [:metadata, :document, :graphics_count])
    def graphics_count
      ng_xml.css("fits > metadata > document > graphicsCount").map(&:text)
    end

    # @!endgroup
    # @!group dicom

    # TODO: Add all these to PROXIED_TERMS

    # t.modality(proxy: [:metadata, :dicom, :modality])
    def modality
      ng_xml.css("fits > metadata > dicom > modality").map(&:text)
    end
  
    # t.spacing_between_slices(proxy: [:metadata, :dicom, :spacing_between_slices])
    def spacing_between_slices
      ng_xml.css("fits > metadata > dicom > spacingBetweenSlices").map(&:text)
    end

    # t.secondary_capture_device_manufacturer(proxy: [:metadata, :dicom, :secondary_capture_device_manufacturer])
    def secondary_capture_device_manufacturer
      ng_xml.css("fits > metadata > dicom > secondaryCaptureDeviceManufacturer").map(&:text)
    end

    # t.secondary_capture_device_software_vers(proxy: [:metadata, :dicom, :secondary_capture_device_software_vers])
    def secondary_capture_device_software_vers
      ng_xml.css("fits > metadata > dicom > secondaryCaptureDeviceSoftwareVers").map(&:text)
    end

    # t.file_type_extension(proxy: [:metadata, :dicom, :file_type_extension])
    def file_type_extension
      ng_xml.css("fits > metadata > dicom > fileTypeExtension").map(&:text)
    end

    # t.image_type(proxy: [:metadata, :dicom, :image_type])
    def image_type
      ng_xml.css("fits > metadata > dicom > imageType").map(&:text)
    end

    # t.study_date(proxy: [:metadata, :dicom, :study_date])
    def study_date
      ng_xml.css("fits > metadata > dicom > studyDate").map(&:text)
    end

    # t.series_date(proxy: [:metadata, :dicom, :series_date])
    def series_date
      ng_xml.css("fits > metadata > dicom > seriesDate").map(&:text)
    end

    # t.content_date(proxy: [:metadata, :dicom, :content_date])
    def content_date
      ng_xml.css("fits > metadata > dicom > contentDate").map(&:text)
    end

    # t.study_time(proxy: [:metadata, :dicom, :study_time])
    def study_time
      ng_xml.css("fits > metadata > dicom > studyTime").map(&:text)
    end

    # t.series_time(proxy: [:metadata, :dicom, :series_time])
    def series_time
      ng_xml.css("fits > metadata > dicom > seriesTime").map(&:text)
    end

    # t.content_time(proxy: [:metadata, :dicom, :content_time])
    def content_time
      ng_xml.css("fits > metadata > dicom > contentTime").map(&:text)
    end

    # t.accession_number(proxy: [:metadata, :dicom, :accession_number])
    def accession_number
      ng_xml.css("fits > metadata > dicom > accessionNumber").map(&:text)
    end

    # t.instance_number(proxy: [:metadata, :dicom, :instance_number])
    def instance_number
      ng_xml.css("fits > metadata > dicom > instanceNumber").map(&:text)
    end

    # t.image_position_patient(proxy: [:metadata, :dicom, :image_position_patient])
    def image_position_patient
      ng_xml.css("fits > metadata > dicom > imagePositionPatient").map(&:text)
    end

    # t.image_orientation_patient(proxy: [:metadata, :dicom, :image_orientation_patient])
    def image_orientation_patient
      ng_xml.css("fits > metadata > dicom > imageOrientationPatient").map(&:text)
    end

    # t.samples_per_pixel(proxy: [:metadata, :dicom, :samples_per_pixel])
    def samples_per_pixel
      ng_xml.css("fits > metadata > dicom > samplesPerPixel").map(&:text)
    end

    # t.photometric_interpretation(proxy: [:metadata, :dicom, :photometric_interpretation])
    def photometric_interpretation
      ng_xml.css("fits > metadata > dicom > photometric_interpretation").map(&:text)
    end
    
    # t.rows(proxy: [:metadata, :dicom, :rows])
    def rows
      ng_xml.css("fits > metadata > dicom > rows").map(&:text)
    end

    # t.columns(proxy: [:metadata, :dicom, :columns])
    def columns
      ng_xml.css("fits > metadata > dicom > columns").map(&:text)
    end

    # t.dicom_height(proxy: [:metadata, :dicom, :height])
    def dicom_height
      ng_xml.css("fits > metadata > dicom > imageHeight").map(&:text)
    end

    # t.dicom_width(proxy: [:metadata, :dicom, :width])
    def dicom_width
      ng_xml.css("fits > metadata > dicom > imageWidth").map(&:text)
    end

    # t.pixel_spacing(proxy: [:metadata, :dicom, :pixel_spacing])
    def pixel_spacing
      ng_xml.css("fits > metadata > dicom > pixelSpacing").map(&:text)
    end

    # t.slice_thickness(proxy: [:metadata, :dicom, :slice_thickness])
    def slice_thickness
      ng_xml.css("fits > metadata > dicom > sliceThickness").map(&:text)
    end

    # t.bits_allocated(proxy: [:metadata, :dicom, :bits_allocated])
    def bits_allocated
      ng_xml.css("fits > metadata > dicom > bitsAllocated").map(&:text)
    end

    # t.bits_stored(proxy: [:metadata, :dicom, :bits_stored])
    def bits_stored
      ng_xml.css("fits > metadata > dicom > bitsStored").map(&:text)
    end

    # t.high_bit(proxy: [:metadata, :dicom, :high_bit])
    def high_bit
      ng_xml.css("fits > metadata > dicom > highBit").map(&:text)
    end

    # t.pixel_representation(proxy: [:metadata, :dicom, :pixel_representation])
    def pixel_representation
      ng_xml.css("fits > metadata > dicom > pixelRepresentation").map(&:text)
    end

    # t.window_center(proxy: [:metadata, :dicom, :window_center])
    def window_center
      ng_xml.css("fits > metadata > dicom > windowCenter").map(&:text)
    end

    # t.window_width(proxy: [:metadata, :dicom, :window_width])
    def window_width
      ng_xml.css("fits > metadata > dicom > windowWidth").map(&:text)
    end

    # t.rescale_intercept(proxy: [:metadata, :dicom, :rescale_intercept])
    def rescale_intercept
      ng_xml.css("fits > metadata > dicom > rescaleIntercept").map(&:text)
    end

    # t.rescale_slope(proxy: [:metadata, :dicom, :rescale_slope])
    def rescale_slope
      ng_xml.css("fits > metadata > dicom > rescaleSlope").map(&:text)
    end

    # t.window_center_and_width_explanation(proxy: [:metadata, :dicom, :window_center_and_width_explanation])
    def window_center_and_width_explanation
      ng_xml.css("fits > metadata > dicom > windowCenterAndWidthExplanation").map(&:text)
    end

    # t.exposure_time(proxy: [:metadata, :dicom, :exposure_time])
    def exposure_time
      ng_xml.css("fits > metadata > dicom > exposureTime").map(&:text)
    end

    # t.pixel_spacing_calibration_description(proxy: [:metadata, :dicom, :pixel_spacing_calibration_description])
    def pixel_spacing_calibration_description
      ng_xml.css("fits > metadata > dicom > pixelSpacingCalibrationDescription").map(&:text)
    end

    # t.pixel_spacing_calibration_type(proxy: [:metadata, :dicom, :pixel_spacing_calibration_type])
    def pixel_spacing_calibration_type
      ng_xml.css("fits > metadata > dicom > pixelSpacingCalibrationType").map(&:text)
    end

    # t.contrast_frame_averaging(proxy: [:metadata, :dicom, :contrast_frame_averaging])
    def contrast_frame_averaging
      ng_xml.css("fits > metadata > dicom > contrastFrameAveraging").map(&:text)
    end

    # t.images_in_acquisition(proxy: [:metadata, :dicom, :images_in_acquisition])
    def images_in_acquisition
      ng_xml.css("fits > metadata > dicom > imagesInAcquisition").map(&:text)
    end

    # t.KVP(proxy: [:metadata, :dicom, :KVP])
    def KVP
      ng_xml.css("fits > metadata > dicom > KVP").map(&:text)
    end

    # t.generator_power(proxy: [:metadata, :dicom, :generator_power])
    def generator_power
      ng_xml.css("fits > metadata > dicom > generatorPower").map(&:text)
    end

    # t.x_ray_tube_current(proxy: [:metadata, :dicom, :x_ray_tube_current])
    def x_ray_tube_current
      ng_xml.css("fits > metadata > dicom > XRayTubeCurrent").map(&:text)
    end

    # t.container_description(proxy: [:metadata, :dicom, :container_description])
    def container_description
      ng_xml.css("fits > metadata > dicom > containerDescription").map(&:text)
    end

    # t.generator_id(proxy: [:metadata, :dicom, :generator_id])
    def generator_id
      ng_xml.css("fits > metadata > dicom > generatorID").map(&:text)
    end

    # t.detector_description(proxy: [:metadata, :dicom, :detector_description])
    def detector_description
      ng_xml.css("fits > metadata > dicom > detectorDescription").map(&:text)
    end

    # t.distance_source_to_patient(proxy: [:metadata, :dicom, :distance_source_to_patient])
    def distance_source_to_patient
      ng_xml.css("fits > metadata > dicom > distanceSourceToPatient").map(&:text)
    end

    # t.distance_source_to_detector(proxy: [:metadata, :dicom, :distance_source_to_detector])
    def distance_source_to_detector
      ng_xml.css("fits > metadata > dicom > distanceSourceToDetector").map(&:text)
    end

    # t.anode_target_material(proxy: [:metadata, :dicom, :anode_target_material])
    def anode_target_material
      ng_xml.css("fits > metadata > dicom > anodeTargetMaterial").map(&:text)
    end

    # t.spiral_pitch_factor(proxy: [:metadata, :dicom, :spiral_pitch_factor])
    def spiral_pitch_factor
      ng_xml.css("fits > metadata > dicom > spiralPitchFactor").map(&:text)
    end

    # t.number_of_series_related_instances(proxy: [:metadata, :dicom, :number_of_series_related_instances])
    def number_of_series_related_instances
      ng_xml.css("fits > metadata > dicom > numberOfSeriesRelatedInstances").map(&:text)
    end

    # @!endgroup
    # @!group image

    # t.byte_order(proxy: [:metadata, :image, :byte_order])
    def byte_order
      ng_xml.css("fits > metadata > image > byteOrder").map(&:text)
    end

    # t.compression(proxy: [:metadata, :image, :compression])
    def compression
      ng_xml.css("fits > metadata > image > compressionScheme").map(&:text)
    end

    # t.height(proxy: [:metadata, :image, :height])
    def height
      ng_xml.css("fits > metadata > image > imageHeight").map(&:text)
    end

    # t.width(proxy: [:metadata, :image, :width])
    def width
      ng_xml.css("fits > metadata > image > imageWidth").map(&:text)
    end

    #  t.color_space(proxy: [:metadata, :image, :color_space])
    def color_space
      ng_xml.css("fits > metadata > image > colorSpace").map(&:text)
    end

    # t.profile_name(proxy: [:metadata, :image, :profile_name])
    def profile_name
      ng_xml.css("fits > metadata > image > iccProfileName").map(&:text)
    end

    # t.profile_version(proxy: [:metadata, :image, :profile_version])
    def profile_version
      ng_xml.css("fits > metadata > image > iccProfileVersion").map(&:text)
    end

    # t.orientation(proxy: [:metadata, :image, :orientation])
    def orientation
      ng_xml.css("fits > metadata > image > orientation").map(&:text)
    end

    # t.color_map(proxy: [:metadata, :image, :color_map])
    def color_map
      ng_xml.css("fits > metadata > image > colorMap").map(&:text)
    end

    # t.image_producer(proxy: [:metadata, :image, :image_producer])
    def image_producer
      ng_xml.css("fits > metadata > image > imageProducer").map(&:text)
    end

    # t.capture_device(proxy: [:metadata, :image, :capture_device])
    def capture_device
      ng_xml.css("fits > metadata > image > captureDevice").map(&:text)
    end

    # t.scanning_software(proxy: [:metadata, :image, :scanning_software])
    def scanning_software
      ng_xml.css("fits > metadata > image > scanningSoftwareName").map(&:text)
    end

    # t.exif_version(proxy: [:metadata, :image, :exif_version])
    def exif_version
      ng_xml.css("fits > metadata > image > exifVersion[toolname='Exiftool']").map(&:text)
    end

    # t.gps_timestamp(proxy: [:metadata, :image, :gps_timestamp])
    def gps_timestamp
      ng_xml.css("fits > metadata > image > gpsTimeStamp").map(&:text)
    end

    # t.latitude(proxy: [:metadata, :image, :latitude])
    def latitude
      ng_xml.css("fits > metadata > image > gpsDestLatitude").map(&:text)
    end

    # t.longitude(proxy: [:metadata, :image, :longitude])
    def longitude
      ng_xml.css("fits > metadata > image > gpsDestLongitude").map(&:text)
    end

    # t.bits_per_sample(proxy: [:metadata, :image, :bits_per_sample])
    def bits_per_sample
      ng_xml.css("fits > metadata > image > bitsPerSample").map(&:text)
    end

    # t.focal_length(proxy: [:metadata, :image, :focal_length])
    def focal_length
      ng_xml.css("fits > metadata > image > focalLength").map(&:text)
    end

    # t.iso_speed_ratings(proxy: [:metadata, :image, :iso_speed_ratings])
    def iso_speed_ratings
      ng_xml.css("fits > metadata > image > isoSpeedRating").map(&:text)
    end

    # t.aperture_value(proxy: [:metadata, :image, :aperture_value])
    def aperture_value
      ng_xml.css("fits > metadata > image > apertureValue").map(&:text)
    end

    # t.shutter_speed(proxy: [:metadata, :image, :shutter_speed])
    def shutter_speed
      ng_xml.css("fits > metadata > image > shutterSpeedValue").map(&:text)
    end

    # @!endgroup
    # @!group video

    # t.video_height(proxy: [:metadata, :video, :height])
    def video_height
      ng_xml.css("fits > metadata > video > imageHeight").map(&:text)
    end

    # t.video_width(proxy: [:metadata, :video, :width])
    def video_width
      ng_xml.css("fits > metadata > video > imageWidth").map(&:text)
    end

    # t.video_duration(proxy: [:metadata, :video, :duration])
    def video_duration
      ng_xml.css("fits > metadata > video > duration").map(&:text)
    end

    # t.video_bit_rate(proxy: [:metadata, :video, :bit_rate])
    def video_bit_rate
      ng_xml.css("fits > metadata > video > bitRate").map(&:text)
    end

    # t.video_sample_rate(proxy: [:metadata, :video, :sample_rate])
    def video_sample_rate
      ng_xml.css("fits > metadata > video > sampleRate").map(&:text)
    end

    # t.video_audio_sample_rate(proxy: [:metadata, :video, :audio_sample_rate])
    def video_audio_sample_rate
      ng_xml.css("fits > metadata > video > audioSampleRate").map(&:text)
    end

    # t.frame_rate(proxy: [:metadata, :video, :frame_rate])
    def frame_rate
      ng_xml.css("fits > metadata > video > frameRate").map(&:text)
    end

    # for fits 1
    # t.video_track_height(proxy: [:metadata, :video, :track, :height])
    def video_track_height
      ng_xml.css("fits > metadata > video > track[type='video'] > height").map(&:text)
    end

    # for fits 1
    # t.video_track_width(proxy: [:metadata, :video, :track, :width])
    def video_track_width
      ng_xml.css("fits > metadata > video > track[type='video'] > width").map(&:text)
    end

    # t.track_frame_rate(proxy: [:metadata, :video, :track, :frame_rate])
    def track_frame_rate
      ng_xml.css("fits > metadata > video > track[type='video'] > frameRate").map(&:text)
    end

    # t.aspect_ratio(proxy: [:metadata, :video, :track, :aspect_ratio])
    def aspect_ratio
      ng_xml.css("fits > metadata > video > track[type='video'] > aspectRatio").map(&:text)
    end

    # @!endgroup
    # @!group audio

    # t.audio_duration(proxy: [:metadata, :audio, :duration])
    def audio_duration
      ng_xml.css("fits > metadata > audio > duration").map(&:text)
    end

    # t.bit_depth(proxy: [:metadata, :audio, :bit_depth])
    def bit_depth
      ng_xml.css("fits > metadata > audio > bitDepth").map(&:text)
    end

    # t.audio_bit_rate(proxy: [:metadata, :audio, :bit_rate])
    def audio_bit_rate
      ng_xml.css("fits > metadata > audio > bitRate").map(&:text)
    end

    # t.audio_sample_rate(proxy: [:metadata, :audio, :sample_rate])
    def audio_sample_rate
      ng_xml.css("fits > metadata > audio > sampleRate").map(&:text)
    end

    # t.channels(proxy: [:metadata, :audio, :channels])
    def channels
      ng_xml.css("fits > metadata > audio > channels").map(&:text)
    end

    # t.data_format(proxy: [:metadata, :audio, :data_format])
    def data_format
      ng_xml.css("fits > metadata > audio > dataFormatType").map(&:text)
    end

    # t.offset(proxy: [:metadata, :audio, :offset])
    def offset
      ng_xml.css("fits > metadata > audio > offset").map(&:text)
    end

    # @!endgroup
    # @!group text

    # t.character_set(proxy: [:metadata, :text, :character_set])
    def character_set
      ng_xml.css("fits > metadata > text > charset").map(&:text)
    end

    # t.markup_basis(proxy: [:metadata, :text, :markup_basis])
    def markup_basis
      ng_xml.css("fits > metadata > text > markupBasis").map(&:text)
    end

    # t.markup_language(proxy: [:metadata, :text, :markup_language])
    def markup_language
      ng_xml.css("fits > metadata > text > markupLanguage").map(&:text)
    end

    # @!endgroup

    # Cleanup phase; ugly name to avoid collisions.
    # The send construct here is required to fix up values because the setters
    # are not defined, but rather applied with method_missing.
    def __cleanup__
      # Add any other scrubbers here; don't return any particular value
      nil
    end

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fits(xmlns: 'http://hul.harvard.edu/ois/xml/ns/fits/fits_output',
                 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                 'xsi:schemaLocation' => "http://hul.harvard.edu/ois/xml/ns/fits/fits_output
                 http://hul.harvard.edu/ois/xml/xsd/fits/fits_output.xsd",
                 version: '0.6.0', timestamp: '1/25/12 11:04 AM') do
          xml.identification { xml.identity(toolname: 'FITS') }
        end
      end
      builder.doc
    end
  end
end
