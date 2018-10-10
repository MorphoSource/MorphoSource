# Generated via
#  `rails generate hyrax:work ImageCaptureEvent`
require 'rails_helper'

RSpec.describe Hyrax::ImageCaptureEventPresenter do

    subject(:presenter) { described_class.new(SolrDocument.new(work.to_solr), nil) }

    let(:description)  {['test']}
    let(:creator)  {['test']}
    let(:title)  {['test']}
    let(:software)  {['test']}
    let(:ice_modality)  {['test']}
    # X-ray CT metadata
    let(:exposure_time)  {['test']}
    let(:flux_normalization)  {['test']}
    let(:geometric_calibration)  {['test']}
    let(:shading_correction)  {['test']}
    let(:filter_material)  {['test']}
    let(:filter_thickness)  {['test']}
    let(:frame_averaging)  {['test']}
    let(:projections)  {['test']}
    let(:voltage)  {['test']}
    let(:power)  {['test']}
    let(:amperage)  {['test']}
    let(:surrounding_material)  {['test']}
    let(:xray_tube_type)  {['test']}
    let(:target_type)  {['test']}
    let(:detector_type)  {['test']}
    let(:detector_configuration)  {['test']}
    let(:source_object_distance)  {['test']}
    let(:source_detector_distance)  {['test']}
    let(:target_material)  {['test']}
    let(:rotation_number)  {['test']}
    let(:phase_contrast)  {['test']}
    let(:optical_magnification)  {['test']}
    # Photogrammetry properties
    let(:focal_length_type)  {['test']}
    let(:background_removal)  {['test']}
    # Photogrammetry properties and Photography properties
    let(:lens_make)  {['test']}
    let(:lens_model)  {['test']}
    let(:light_source)  {['test']}

    let(:visibility)              { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:user)                    { 'test@example.com' }

    let :work do
        ImageCaptureEvent.create(
            description: description,
            creator: creator,
            title: title,
            software: software,
            ice_modality: ice_modality,

            exposure_time: exposure_time,
            flux_normalization: flux_normalization,
            geometric_calibration: geometric_calibration,
            shading_correction: shading_correction,
            filter_material: filter_material,
            filter_thickness: filter_thickness,
            frame_averaging: frame_averaging,
            projections: projections,
            voltage: voltage,
            power: power,
            amperage: amperage,
            surrounding_material: surrounding_material,
            xray_tube_type: xray_tube_type,
            target_type: target_type,
            detector_type: detector_type,
            detector_configuration: detector_configuration,
            source_object_distance: source_object_distance,
            source_detector_distance: source_detector_distance,
            target_material: target_material,
            rotation_number: rotation_number,
            phase_contrast: phase_contrast,
            optical_magnification: optical_magnification,

            focal_length_type: focal_length_type,
            background_removal: background_removal,

            lens_make: lens_make,
            lens_model: lens_model,
            light_source: light_source
	            
        )
  end

  it { is_expected.to have_attributes(
            description: description,
            creator: creator,
            title: title,
            software: software,
            ice_modality: ice_modality,

            exposure_time: exposure_time,
            flux_normalization: flux_normalization,
            geometric_calibration: geometric_calibration,
            shading_correction: shading_correction,
            filter_material: filter_material,
            filter_thickness: filter_thickness,
            frame_averaging: frame_averaging,
            projections: projections,
            voltage: voltage,
            power: power,
            amperage: amperage,
            surrounding_material: surrounding_material,
            xray_tube_type: xray_tube_type,
            target_type: target_type,
            detector_type: detector_type,
            detector_configuration: detector_configuration,
            source_object_distance: source_object_distance,
            source_detector_distance: source_detector_distance,
            target_material: target_material,
            rotation_number: rotation_number,
            phase_contrast: phase_contrast,
            optical_magnification: optical_magnification,

            focal_length_type: focal_length_type,
            background_removal: background_removal,

            lens_make: lens_make,
            lens_model: lens_model,
            light_source: light_source
      ) 
    }

end
