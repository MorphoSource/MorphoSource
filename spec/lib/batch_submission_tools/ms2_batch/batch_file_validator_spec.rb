require 'rails_helper'

RSpec.describe BatchSubmissionTools::Ms2Batch::BatchFileValidator do
  let(:user) { User.create(email: 'validator@example.com', password: 'password', sftp_share: '/tmp') }
  let(:xlsx_file) { instance_double(Roo::Excelx) }
  let(:cell_struct) { Struct.new(:value) }

  let(:modality) { 'Photogrammetry' }
  subject(:validator) { described_class.new(xlsx_file: xlsx_file, user: user, modality: modality) }

  describe '#error_found' do
    def error_for(field_name, value, row: 8)
      cell = value.nil? ? nil : cell_struct.new(value)
      validator.send(:error_found, field_name, cell, row)
    end

    it 'returns an error when media file is missing' do
      error_msg, warn_msg = error_for('media.media_file', nil)

      expect(error_msg).to eq('media.media_file: Please enter a value.')
      expect(warn_msg).to eq('')
    end

    it 'returns an error for invalid media file name' do
      error_msg, _warn_msg = error_for('media.media_file', 'file with space.zip')

      expect(error_msg).to eq(
        'media.media_file: File name file with space.zip is not valid.  Please use a valid file name (alphanumeric, dashes or underscores, with a valid file extension).'
      )
    end

    it 'returns an error when parent_file is set along with parent_ms_id' do
      allow(validator).to receive(:field_column).with('media.parent_ms_id').and_return(1)
      allow(validator).to receive(:cell_value).with(8, 1).and_return('000000123')

      error_msg, _warn_msg = error_for('media.parent_file', 'parent_file.zip')

      expect(error_msg).to eq('A value can be present in media.parent_file or media.parent_ms_id, but not in both.')
    end

    it 'returns an error when parent_ms_id is set for raw media' do
      allow(validator).to receive(:field_column).and_return(1)
      allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
      allow(validator).to receive(:cell_value).and_return(nil)
      allow(validator).to receive(:cell_value).with(8, 2).and_return('Raw')

      error_msg, _warn_msg = error_for('media.parent_ms_id', '123')

      expect(error_msg).to eq("A value cannot be present in media.parent_ms_id if media.raw_or_derived value is set to 'Raw'.")
    end

    it 'returns an error when modality-specific field is present for a different modality' do
      valid_modalities = instance_double('valid_modalities', ignore_case_included_value: 'Photogrammetry')
      allow(validator).to receive(:valid_modalities).and_return(valid_modalities)
      allow(validator).to receive(:modality_for_row).with(8).and_return('Photogrammetry')

      error_msg, _warn_msg = error_for('imaging_event.ct.exposure_time', '100')

      expect(error_msg).to eq('imaging_event.ct.exposure_time: Value should not be present when modality Photogrammetry is pre-selected.')
    end

    context 'with MicroNanoXRayComputedTomography modality' do
      let(:modality) { 'MicroNanoXRayComputedTomography' }

      before do
        allow(validator).to receive(:valid_modalities)
          .and_return(['MicroNanoXRayComputedTomography', 'Photogrammetry', 'Photography'])
      end

      it 'returns a file not found error for media.media_file' do
        allow(validator).to receive(:user_share_full_path).and_return('/tmp/')
        allow(File).to receive(:exist?).with(File.join('/tmp/', 'ANSP_Fish_53046_Head.zip')).and_return(false)

        error_msg, _warn_msg = error_for('media.media_file', 'ANSP_Fish_53046_Head.zip')

        expect(error_msg).to eq('media.media_file: File ANSP_Fish_53046_Head.zip cannot be found. Please check your shared folder.')
      end

      it 'returns a valid media type error when media.media_type is invalid' do
        allow(validator).to receive(:valid_media_types).and_return(
          ['Image', 'Video', 'CTImageSeries', 'PhotogrammetryImageSeries', 'Mesh', 'SequentialSectionImageSeries', 'Other']
        )

        error_msg, _warn_msg = error_for('media.media_type', 'NotAType')

        expect(error_msg).to eq(
          'media.media_type: Please enter a valid value: "Image", "Video", "CTImageSeries", "PhotogrammetryImageSeries", "Mesh", "SequentialSectionImageSeries", "Other"'
        )
      end

      it 'requires a specimen identifier when none are provided' do
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:cell_value).and_return(nil)

        error_msg, _warn_msg = error_for('biological_specimen.ms_id', nil)

        expect(error_msg).to eq(
          'One of the following must have a value: biological_specimen.ms_id, biological_specimen.occurrence_id, biological_specimen.institution_code, biological_specimen.collection_code, biological_specimen.catalog_number, or media.parent_ms_id.'
        )
      end

      it 'returns a date validation error for biological_specimen.date_created' do
        error_msg, _warn_msg = error_for('biological_specimen.date_created', 'not-a-date')

        expect(error_msg).to eq('biological_specimen.date_created: Please enter a valid date in YYYY-MM-DD or MM-DD-YYYY format.')
      end

      it 'returns a boolean validation error for biological_specimen.is_type_specimen' do
        error_msg, _warn_msg = error_for('biological_specimen.is_type_specimen', 'maybe')

        expect(error_msg).to eq(
          'biological_specimen.is_type_specimen: Please enter a valid value: "Yes", "No", "Y", "N", "true", "false", "0", "1"'
        )
      end

      it 'returns a controlled value error for biological_specimen.sex' do
        error_msg, _warn_msg = error_for('biological_specimen.sex', 'Other')

        expect(error_msg).to eq(
          'biological_specimen.sex: Please enter a valid value: "Female", "Male", "Unknowable", "Undetermined", "Hermaphrodite", "Gynandromorph"'
        )
      end

      it 'returns a number validation error for imaging_event.ct.exposure_time' do
        error_msg, _warn_msg = error_for('imaging_event.ct.exposure_time', 'bad')

        expect(error_msg).to eq('imaging_event.ct.exposure_time: Please enter a valid number.')
      end

      it 'returns a controlled value error for imaging_event.ct.target_type' do
        error_msg, _warn_msg = error_for('imaging_event.ct.target_type', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.ct.target_type: Please enter a valid value: "Reflection", "Transmission"'
        )
      end

      it 'returns a controlled value error for imaging_event.ct.detector_type' do
        error_msg, _warn_msg = error_for('imaging_event.ct.detector_type', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.ct.detector_type: Please enter a valid value: "Direct (X-Ray photoconductor)", "Scintillator (Phosphor used)", "Storage (Storage Phosphor)", "Film (Scanned film/screen)"'
        )
      end

      it 'returns an integer validation error for imaging_event.ct.detector_pixels_x' do
        error_msg, _warn_msg = error_for('imaging_event.ct.detector_pixels_x', 'bad')

        expect(error_msg).to eq('imaging_event.ct.detector_pixels_x: Please enter a valid integer.')
      end

      it 'returns an integer validation error for imaging_event.ct.detector_pixels_y' do
        error_msg, _warn_msg = error_for('imaging_event.ct.detector_pixels_y', 'bad')

        expect(error_msg).to eq('imaging_event.ct.detector_pixels_y: Please enter a valid integer.')
      end

      it 'returns a controlled value error for imaging_event.ct.detector_configuration' do
        error_msg, _warn_msg = error_for('imaging_event.ct.detector_configuration', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.ct.detector_configuration: Please enter a valid value: "Area (single or tiled detector)", "Slot (scanned slot, slit, or spot)"'
        )
      end

      it 'returns a controlled value error for imaging_event.ct.acquisition_type' do
        error_msg, _warn_msg = error_for('imaging_event.ct.acquisition_type', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.ct.acquisition_type: Please enter a valid value: "ConstantAngle", "Free", "Sequenced", "Spiral", "Stationary"'
        )
      end

      it 'returns a modality mismatch error for imaging_event.photogrammetry.focal_length_type' do
        error_msg, _warn_msg = error_for('imaging_event.photogrammetry.focal_length_type', 'Fixed')

        expect(error_msg).to eq(
          'imaging_event.photogrammetry.focal_length_type: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
        )
      end

      it 'returns a modality mismatch error for imaging_event.photography.light_source' do
        error_msg, _warn_msg = error_for('imaging_event.photography.light_source', 'Strobe')

        expect(error_msg).to eq(
          'imaging_event.photography.light_source: Value should not be present when modality MicroNanoXRayComputedTomography is pre-selected.'
        )
      end

      it 'requires media.y_spacing for CTImageSeries' do
        allow(validator).to receive(:valid_media_types).and_return(['CTImageSeries'])
        allow(validator).to receive(:field_column).with('media.media_type').and_return(1)
        allow(validator).to receive(:cell_value).with(8, 1).and_return('CTImageSeries')

        error_msg, _warn_msg = error_for('media.y_spacing', nil)

        expect(error_msg).to eq('media.y_spacing: Value should be present for media type CTImageSeries.')
      end

      it 'returns a number validation error for media.z_spacing' do
        allow(validator).to receive(:valid_media_types).and_return(['CTImageSeries'])
        allow(validator).to receive(:field_column).with('media.media_type').and_return(1)
        allow(validator).to receive(:cell_value).with(8, 1).and_return('CTImageSeries')

        error_msg, _warn_msg = error_for('media.z_spacing', 'bad')

        expect(error_msg).to eq('media.z_spacing: Please enter a valid number.')
      end

      it 'returns a not found error for media.parent_ms_id' do
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:cell_value).with(8, 2).and_return('Derived')
        allow(validator).to receive(:parent_media_for_row).with(8).and_return(nil)

        error_msg, _warn_msg = error_for('media.parent_ms_id', 'not_found')

        expect(error_msg).to eq('media.parent_ms_id: Existing media not_found not found.')
      end

      it 'returns a not found error for biological_specimen.ms_id' do
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:specimen_for_row).with(8).and_return(nil)

        error_msg, _warn_msg = error_for('biological_specimen.ms_id', 'not_found')

        expect(error_msg).to eq('biological_specimen.ms_id: Existing biological specimen not_found not found.')
      end

      it 'returns a mismatch error for biological_specimen.institution_code' do
        organization = instance_double(OrganizationCollection, institution_code: ['abc'])
        allow(validator).to receive(:organization_for_row).with(8).and_return(organization)
        allow(validator).to receive(:field_column).with('biological_specimen.ms_id').and_return(1)
        allow(validator).to receive(:cell_value).with(8, 1).and_return(nil)

        error_msg, _warn_msg = error_for('biological_specimen.institution_code', 'xyz')

        expect(error_msg).to eq('biological_specimen.institution_code: Does not match the institution code from the organization: abc')
      end

      it 'returns a parent_file not found error' do
        xlsx = instance_double(Roo::Excelx)
        allow(validator).to receive(:xlsx).and_return(xlsx)
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:cell_value).with(8, 2).and_return('Derived')
        allow(xlsx).to receive(:column).with(1).and_return(['other.zip'])

        error_msg, _warn_msg = error_for('media.parent_file', 'parent_file_not_found.zip')

        expect(error_msg).to eq('media.parent_file parent_file_not_found.zip not found in another row.')
      end

      it 'returns a same-row parent_file error' do
        xlsx = instance_double(Roo::Excelx)
        allow(validator).to receive(:xlsx).and_return(xlsx)
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:cell_value).with(8, 2).and_return('Derived')
        column = Array.new(8)
        column[7] = 'ANSP_Fish_193352_Head.zip'
        allow(xlsx).to receive(:column).with(1).and_return(column)

        error_msg, _warn_msg = error_for('media.parent_file', 'ANSP_Fish_193352_Head.zip')

        expect(error_msg).to eq('media.parent_file ANSP_Fish_193352_Head.zip cannot be media.media_file in the same row.')
      end

      it 'returns a controlled required error for media.raw_or_derived' do
        allow(validator).to receive(:valid_media_types).and_return(['CTImageSeries'])
        allow(validator).to receive(:field_column).with('media.media_type').and_return(1)
        allow(validator).to receive(:cell_value).with(8, 1).and_return('CTImageSeries')

        error_msg, _warn_msg = error_for('media.raw_or_derived', nil)

        expect(error_msg).to eq('media.raw_or_derived: Please enter a valid value.')
      end

      it 'returns a raw parent_file error when media.raw_or_derived is Raw' do
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:cell_value).with(8, 2).and_return('Raw')

        error_msg, _warn_msg = error_for('media.parent_file', 'parent_file.zip')

        expect(error_msg).to eq("A value cannot be present in media.parent_file if media.raw_or_derived value is set to 'Raw'.")
      end

      it 'returns a controlled value error for imaging_event.ct.pixel_spacing_calibration' do
        error_msg, _warn_msg = error_for('imaging_event.ct.pixel_spacing_calibration', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.ct.pixel_spacing_calibration: Please enter a valid value: "Geometry", "Fiducial"'
        )
      end

      it 'returns a keyword validation error for media.keyword' do
        error_msg, _warn_msg = error_for('media.keyword', 'bad$')

        expect(error_msg).to eq('media.keyword: Value(s) must be letters, accented letters, numbers, and spaces. Use comma as separator.')
      end

      it 'returns a remote file permission error for media.media_file' do
        organization = instance_double(OrganizationCollection, id: '0001')
        allow(validator).to receive(:organization_for_row).with(8).and_return(organization)
        allow(user).to receive(:can_submit_remote_file?)
          .with('http://example.com/file.zip', '0001')
          .and_return(false)

        error_msg, _warn_msg = error_for('media.media_file', 'http://example.com/file.zip')

        expect(error_msg).to eq(
          'media.media_file: The remote file path is invalid or not allowed. Please make sure you have remote file submitter permissions, organization member permissions, and that the domain for the remote file is allowed.'
        )
      end

      it 'returns an invalid preview file name error' do
        error_msg, _warn_msg = error_for('media.preview_file', 'file with space.zip')

        expect(error_msg).to eq(
          'media.preview_file: File name file with space.zip is not valid.  Please use a valid file name (alphanumeric, dashes or underscores, with a valid file extension).'
        )
      end
    end

    context 'with Photogrammetry modality' do
      let(:modality) { 'Photogrammetry' }

      before do
        allow(validator).to receive(:valid_modalities)
          .and_return(['MicroNanoXRayComputedTomography', 'Photogrammetry', 'Photography'])
      end

      it 'returns a modality mismatch error for imaging_event.ct.exposure_time' do
        error_msg, _warn_msg = error_for('imaging_event.ct.exposure_time', '10')

        expect(error_msg).to eq('imaging_event.ct.exposure_time: Value should not be present when modality Photogrammetry is pre-selected.')
      end

      it 'returns a controlled value error for imaging_event.photogrammetry.focal_length_type' do
        error_msg, _warn_msg = error_for('imaging_event.photogrammetry.focal_length_type', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.photogrammetry.focal_length_type: Please enter a valid value: "Variable", "Fixed"'
        )
      end

      it 'returns a modality mismatch error for imaging_event.photography.light_source' do
        error_msg, _warn_msg = error_for('imaging_event.photography.light_source', 'Strobe')

        expect(error_msg).to eq(
          'imaging_event.photography.light_source: Value should not be present when modality Photogrammetry is pre-selected.'
        )
      end
    end

    context 'with Photography modality' do
      let(:modality) { 'Photography' }

      before do
        allow(validator).to receive(:valid_modalities)
          .and_return(['MicroNanoXRayComputedTomography', 'Photogrammetry', 'Photography'])
      end

      it 'returns a modality mismatch error for imaging_event.ct.acquisition_type' do
        error_msg, _warn_msg = error_for('imaging_event.ct.acquisition_type', 'Free')

        expect(error_msg).to eq(
          'imaging_event.ct.acquisition_type: Value should not be present when modality Photography is pre-selected.'
        )
      end

      it 'returns a modality mismatch error for imaging_event.photogrammetry.focal_length_type' do
        error_msg, _warn_msg = error_for('imaging_event.photogrammetry.focal_length_type', 'Fixed')

        expect(error_msg).to eq(
          'imaging_event.photogrammetry.focal_length_type: Value should not be present when modality Photography is pre-selected.'
        )
      end

      it 'returns a controlled value error for imaging_event.photography.light_source' do
        error_msg, _warn_msg = error_for('imaging_event.photography.light_source', 'Bad')

        expect(error_msg).to eq(
          'imaging_event.photography.light_source: Please enter a valid value: "Strobe", "Static", "Patterned", "Cross polarized"'
        )
      end
    end

    context 'with parent and specimen validation' do
      it 'returns an invalid parent chain error for media.parent_file' do
        xlsx = instance_double(Roo::Excelx)
        allow(validator).to receive(:xlsx).and_return(xlsx)
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:field_column).with('media.raw_or_derived').and_return(2)
        allow(validator).to receive(:field_column).with('media.parent_file').and_return(3)
        allow(validator).to receive(:cell_value).and_return(nil)
        allow(validator).to receive(:cell_value).with(8, 2).and_return('Derived')
        allow(validator).to receive(:cell_value).with(10, 3).and_return('ANSP_Fish_180334_Head.jpg')
        column = Array.new(10)
        column[9] = 'ANSP_Fish_180334_Head.jpg'
        allow(xlsx).to receive(:column).with(1).and_return(column)

        error_msg, _warn_msg = error_for('media.parent_file', 'ANSP_Fish_180334_Head.jpg')

        expect(error_msg).to eq(
          'media.parent_file ANSP_Fish_180334_Head.jpg has invalid parent(s) (found in row 10).  Please check and make sure each parent_file is pointing to the correct row.'
        )
      end

      it 'returns an organization mismatch error for biological_specimen.ms_id' do
        specimen = instance_double(SolrDocument, organization_id: ['ORG1'])
        allow(validator).to receive(:organization_for_row).with(8).and_return(instance_double(OrganizationCollection, id: 'ORG2'))
        allow(validator).to receive(:specimen_for_row).with(8).and_return(specimen)
        allow(validator).to receive(:field_column).and_return(1)
        allow(validator).to receive(:cell_value).and_return(nil)

        error_msg, _warn_msg = error_for('biological_specimen.ms_id', 'TESTBSO123')

        expect(error_msg).to eq(
          'biological_specimen.ms_id: Existing biological specimen TESTBSO123 is associated with an organization different from the one you have selected.'
        )
      end
    end
  end

  describe '#initial_error_message' do
    let(:xlsx) { instance_double(Roo::Excelx) }

    before do
      allow(validator).to receive(:xlsx).and_return(xlsx)
    end

    it 'returns an error when columns are invalid' do
      allow(xlsx).to receive(:last_column).and_return(86)

      expect(validator.send(:initial_error_message)).to eq(
        'The columns are invalid.  Please check the file or download the latest blank submission manifest again.'
      )
    end

    it 'returns an error when row count exceeds the maximum' do
      allow(xlsx).to receive(:last_column).and_return(85)
      allow(xlsx).to receive(:last_row).and_return(5008)

      expect(validator.send(:initial_error_message)).to eq('The number of rows has exceeded the maximum.')
    end

    it 'returns an error when a field name does not match expectations' do
      allow(xlsx).to receive(:last_column).and_return(85)
      allow(xlsx).to receive(:last_row).and_return(10)
      allow(validator).to receive(:field_names).and_return(['media.media_file'])
      allow(xlsx).to receive(:excelx_value).with(7, 3).and_return('wrong')

      expect(validator.send(:initial_error_message)).to eq(
        'Invalid field name in row 7, column 3 (expecting media.media_file).  Please check the file or download the blank submission manifest again.'
      )
    end

    it 'returns an error when the field name mismatch references pixel spacing calibration' do
      allow(xlsx).to receive(:last_column).and_return(85)
      allow(xlsx).to receive(:last_row).and_return(10)
      allow(validator).to receive(:field_names).and_return(['imaging_event.ct.pixel_spacing_calibration'])
      allow(xlsx).to receive(:excelx_value).with(7, 3).and_return('wrong')

      expect(validator.send(:initial_error_message)).to eq(
        'Invalid field name in row 7, column 3 (expecting imaging_event.ct.pixel_spacing_calibration).  Please check the file or download the blank submission manifest again.'
      )
    end
  end
end
