# Generated via
#  `rails generate hyrax:work ImagingEvent`
require 'rails_helper'

RSpec.describe Hyrax::ImagingEventPresenter do

    subject(:presenter) { described_class.new(SolrDocument.new(work.to_solr), nil) }

    let(:device)  { Device.create(title:['device'], modality: ['Photogrammetry']) }

    let(:description)  {['test']}
    let(:creator)  {['test']}
    let(:title)  {['test']}
    let(:software)  {['test']}
    let(:device_id) { [device.id] }
    let(:ie_modality)  { device.modality }
    # X-ray CT metadata
    let(:exposure_time)  {['test']}
    let(:flux_normalization)  {['test']}
    let(:pixel_spacing_calibration)  {['test']}
    let(:shading_correction)  {['test']}
    let(:ie_filter)  {['test']}
    let(:frame_averaging)  {['test']}
    let(:projections)  {['test']}
    let(:voltage)  {['test']}
    let(:power)  {['test']}
    let(:amperage)  {['test']}
    let(:surrounding_material)  {['test']}
    let(:xray_tube_type)  {['test']}
    let(:target_type)  {['test']}
    let(:detector_type)  {['test']}
    let(:detector_pixels_x) {['test']}
    let(:detector_pixel_size_x) {['test']}
    let(:detector_pixels_y) {['test']}
    let(:detector_pixel_size_y) {['test']}
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
    let(:id)                      { 'aaa' }

    let :work do
        ImagingEvent.create(
            id: id,
            description: description,
            creator: creator,
            title: title,
            software: software,
            device_id: device_id,
            ie_modality: ie_modality,

            exposure_time: exposure_time,
            flux_normalization: flux_normalization,
            pixel_spacing_calibration: pixel_spacing_calibration,
            shading_correction: shading_correction,
            ie_filter: ie_filter,
            frame_averaging: frame_averaging,
            projections: projections,
            voltage: voltage,
            power: power,
            amperage: amperage,
            surrounding_material: surrounding_material,
            xray_tube_type: xray_tube_type,
            target_type: target_type,
            detector_type: detector_type,
            detector_pixels_x: detector_pixels_x,
            detector_pixel_size_x: detector_pixel_size_x,
            detector_pixels_y: detector_pixels_y,
            detector_pixel_size_y: detector_pixel_size_y,
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
            title: ["IE#{id}: #{title.first}"],
            software: software,
            device_id: device_id,
            ie_modality: ie_modality,

            exposure_time: exposure_time,
            flux_normalization: flux_normalization,
            pixel_spacing_calibration: pixel_spacing_calibration,
            shading_correction: shading_correction,
            ie_filter: ie_filter,
            frame_averaging: frame_averaging,
            projections: projections,
            voltage: voltage,
            power: power,
            amperage: amperage,
            surrounding_material: surrounding_material,
            xray_tube_type: xray_tube_type,
            target_type: target_type,
            detector_type: detector_type,
            detector_pixels_x: detector_pixels_x,
            detector_pixel_size_x: detector_pixel_size_x,
            detector_pixels_y: detector_pixels_y,
            detector_pixel_size_y: detector_pixel_size_y,
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
