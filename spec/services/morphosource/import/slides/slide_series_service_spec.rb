# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Import::Slides::SlideSeriesService do

  let!(:providers)      { YAML.load_file('config/import/slides/providers.yml') }
  let!(:provider)       { providers.first }
  let!(:manager)        { User.create(email: 'manager@email.com', password: 'password', ms_id: provider['manager']) }
  let!(:manager)        { FactoryBot.create(:user, ms_id: provider['manager']) }
  let!(:organization)   { FactoryBot.create(:organization_collection, id: provider['id'], depositor: manager.ms_id) }
  let!(:device)         { FactoryBot.create(:device, title: [device_name], modality: ['SequentialSectionScan'], organization_id: [organization.id]) }

  let(:collection)      { double('collection') }
  let(:occurrence_key)  { 4003219413 }
  let(:taxon_key)       { '5216061' }
  let(:occurrence_id)   { 'MCZ:SC:3793' }
  let(:specimen_uri)    { 'http://mczbase.mcz.harvard.edu/guid/MCZ:SC:3793' }
  let(:device_name)     { 'TissueScope LE 120' }
  let(:slide_title)     { 'MCZ_SC-3793_slide-1' }
  let(:file_name)       { "#{slide_title}.tif" }
  let(:base_uri)        { 'https://iiif.mcz.harvard.edu/iiif/3/3823260/' }
  let(:import_url)      { "#{base_uri}full/max/0/default.tif" }

  let(:slide_json) do
    {
      'http://rs.tdwg.org/ac/terms/variant' => 'ac:BestQuality',
      'http://purl.org/dc/elements/1.1/format' => 'image/png',
      'http://purl.org/dc/elements/1.1/rights' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode',
      'http://purl.org/dc/elements/1.1/type' => 'StillImage',
      'http://purl.org/dc/terms/identifier' => 'http://mczbase.mcz.harvard.edu/media/3823260',
      'http://rs.tdwg.org/ac/terms/associatedSpecimenReference' => 'http://mczbase.mcz.harvard.edu/guid/MCZ:SC:3793',
      'http://purl.org/dc/terms/description' => slide_title,
      'http://ns.adobe.com/xap/1.0/rights/UsageTerms' => 'Available under Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA) license',
      'http://rs.tdwg.org/ac/terms/resourceCreationTechnique' => 'Sequential Section Scan',
      'http://rs.tdwg.org/ac/terms/accessURI' => 'https://iiif.mcz.harvard.edu/iiif/3/3823260/full/max/0/default.png',
      'http://rs.tdwg.org/dwc/terms/preparations' => "{\"embedding material\":\"paraffin\",\"part_name\":\"histological serial section\",\"preserve_method\":\"histological slide\",\"section interval\":\"0\",\"section plane\":\"transverse\",\"section stain\":\"Bodian and Cresyl Violet\",\"section thickness\":\"15\"}",
      'http://purl.org/dc/terms/rights' => 'http://creativecommons.org/licences/by-nc-sa/3.0/legalcode',
      'http://rs.tdwg.org/dwc/terms/scientificName' => 'Raja eglanteria'
    }
  end

  let(:occurrence_json) do
    {
      'key' => occurrence_key,
      'publishingOrgKey' => provider['publishing_org_key'],
      'taxonKey' => taxon_key,
      'occurrenceID' => occurrence_id,
      'references' => specimen_uri,
      'extensions' => {
        'http://rs.tdwg.org/ac/terms/Multimedia' => [slide_json]
      }
    }
  end

  let(:iiif_json) do
    {
      'id' => 'http://iiif.mcz.harvard.edu/iiif/3/3823260',
      'exif' => iiif_exif,
      'originalFilename' => file_name,
      'fileSize' => 3325675996
    }
  end

  let(:iiif_exif) do
    {
      'fields' => {
        'ImageWidth' => 154431,
        'ImageLength' => 223142,
        'BitsPerSample' => 8,
        'Compression' => 7,
        'PhotometricInterpretation' => 6,
        'ImageDescription' => "Scan Size = 38.61x55.79 mm\nImage Dimensions = 154431x223142 Pixels\nResolution = 0.25 um\nSource = Bright Field\nScan Started = 2023:03:20 13:04:34\nScan Duration = 00:32:19\nCompress Option = JPEG\nCompress Method = Lossy\nImage Quality = 0.900000\n",
        'Make' => 'Huron Digital Pathology',
        'Model' => device_name,
        'XResolution' => { 'numerator' => 40000, 'denominator' => 1 },
        'YResolution' => { 'numerator' => 40000, 'denominator' => 1 },
        'ResolutionUnit' => 3,
        'Software' => 'MACROscan 1.32',
        'DateTime' => '2023:03:20 13:04:34'
      }
    }
  end

  let(:specimen_params) do
    {
      :idigbio_uuid => ["839cda9b-ec88-494c-ab0c-1fca327a70d6"],
      :idigbio_recordset_id => ["271a9ce9-c6d3-4b63-a722-cb0adc48863f"],
      :vouchered => ["Yes"],
      :institution_code => ["MCZ"],
      :collection_code => ["SC"],
      :catalog_number => ["3793"],
      :occurrence_id => ["MCZ:SC:3793"],
      :related_url => ["http://mczbase.mcz.harvard.edu/guid/MCZ:SC:3793"],
      :creator => ["[no agent data]"],
      :original_location => ["[no specific locality data]"]
    }
  end

  let(:taxonomy_params) do
    {
      :taxonomy_kingdom=>["Animalia"],
      :taxonomy_phylum=>["Chordata"],
      :taxonomy_class=>["Elasmobranchii"],
      :taxonomy_order=>["Rajiformes"],
      :taxonomy_family=>["Rajidae"],
      :taxonomy_genus=>["Raja"],
      :gbif_key=>["5216061"],
      :taxonomy_species=>["eglanteria"]
    }
  end

  subject     { described_class.new(occurrence_key) }
  let(:slide) { subject.send(:slide_class).new(slide_json) }

  before do
    allow_any_instance_of(described_class).to receive(:occurrence_json).and_return(occurrence_json) # response from GBIF
    allow_any_instance_of(described_class).to receive(:specimen_params_from_occurrence_id).and_return(specimen_params) # response from iDigBio
    allow_any_instance_of(described_class).to receive(:taxonomy_params_from_gbif).and_return(taxonomy_params) # response from GBIF
    allow_any_instance_of(Morphosource::Import::SlideSeries::Slides::MczSlide).to receive(:iiif_json).and_return(iiif_json) # response from MCZ
    allow(Collection).to receive(:find).and_call_original
    # organization.managers << manager
    # organization.managers_group.save
  end

  describe '.call' do
    subject { described_class.call(occurrence_key) }
    before do
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
      allow_any_instance_of(described_class).to receive(:call).and_return(true)

    end
    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
    end
  end

  describe 'call' do
    subject { described_class.call(occurrence_key) }
    it 'calls methods to create the slide series and returns the collection' do
      expect_any_instance_of(described_class).to receive(:find_or_create_series_works)
      expect_any_instance_of(described_class).to receive(:import_slide_series)
      expect(subject).to be_a(SequentialSectionList)
    end
  end

  describe 'import_slide_series' do
    let(:media) { double('media', id: 'media123') }
    before do
      # subject.instance_variable_set(:@media, media)
      allow(subject).to receive(:create_new_media).and_return(media)
    end
    it 'calls methods to create a new media record and add it to the collection' do
      expect(subject).to receive(:create_new_imaging_event)
      expect(subject).to receive(:create_new_media)
      expect(subject).to receive(:characterize_file)
      expect(subject).to receive(:create_thumbnail)
      expect_any_instance_of(SequentialSectionList).to receive(:add_member_objects)
      subject.call
    end
  end

  describe 'find_or_create_specimen' do
    before do
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
    end
    context 'specimen exists' do
      let!(:specimen)  { BiologicalSpecimen.create(title: ['specimen'], occurrence_id: [occurrence_id], organization_id: [organization.id]) }
      it 'returns the created specimen' do
        expect(subject.find_or_create_specimen).to eq(specimen)
      end
    end
    context 'specimen does not exist' do
      it 'creates a new specimen' do
        specimen = subject.find_or_create_specimen
        expect(specimen.occurrence_id).to eq([occurrence_id])
      end
    end
  end

  describe 'search_for_specimen' do
    let(:occurrence_id)       { 'MCZ:SC:4009' }
    let(:doc_id_1)            { 'MCZ' }
    let(:doc_id_2)            { 'SC' }
    let(:doc_id_3)            { '4009' }
    let(:doc_ids)             { [doc_id_1, doc_id_2, doc_id_3] }

    before do
      occurrence_json['occurrenceID'] = occurrence_id
      # create a record for each doc_id
      doc_ids.each_with_index do |id, i|
        ActiveFedora::SolrService.add( { 'id': i,
                                         'has_model_ssim': { 'set' => 'BiologicalSpecimen' },
                                         'occurrence_id_ssim': { 'set' => [id] }
                                       }, softCommit: true)
      end
    end

    context 'the record for the specimen exists' do
      before do
        ActiveFedora::SolrService.add( { 'id': 'occurrence_id',
                                         'has_model_ssim': { 'set' => 'BiologicalSpecimen' },
                                         'occurrence_id_ssim': { 'set' => [occurrence_id] }
                                       }, softCommit: true)
      end
      it 'returns the solr hit' do
        specimen = subject.send(:search_for_specimen)
        expect(specimen['occurrence_id_ssim'].first).to eq(occurrence_id)
      end
    end

    context 'record for the specimen does not exist' do
      it 'returns nil' do
        expect(subject.send(:search_for_specimen)).to eq(nil)
      end
    end
  end

  describe 'taxonomy' do
    before do
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
    end
    context 'taxonomy exists' do
      let!(:taxonomy)  { valkyrie_create(:taxonomy_resource, title: ['taxonomy'], gbif_key: [taxon_key]) }
      it 'returns the created taxonomy' do
        expect(subject.taxonomy).to eq(taxonomy)
      end
    end
    context 'taxonomy does not exist' do
      it 'creates a new taxonomy' do
        taxonomy = subject.taxonomy
        expect(taxonomy.gbif_key).to eq([taxon_key.to_s])
        expect(taxonomy.source).to eq(['Imported by Morphosource::Import::SlideSeriesService'])
      end
    end
  end

  describe 'create_series_collection' do
    it 'creates a sequential section list' do
      list = subject.instance_variable_get(:@collection)
      expect(list.collection_type.title).to eq('Sequential Section List')
      expect(list.depositor).to eq(provider['manager'])
      expect(list.edit_groups).to match_array(["#{list.id}_managers", 'admin'])
      expect(list.read_groups).to match_array(["#{list.id}_viewers", 'public'])
      expect(list.managers).to include(manager)
    end
  end

  describe 'create_new_imaging_event' do
    before do
      subject.instance_variable_set(:@slide, slide)
      subject.instance_variable_set(:@specimen, double('specimen', id: 'spec123'))
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
      allow(slide).to receive(:validate_technical_metadata).and_return(true)
    end
    it 'creates an imaging event' do
      event = subject.create_new_imaging_event
      title = ["IE#{event.id}: #{device_name} SequentialSectionScan Imaging Event (2023-03-20)"]
      expect(event.depositor).to eq(manager.ms_id)
      expect(event.edit_users).to match_array([manager.ms_id])
      expect(manager.can? :edit, event).to be(true)
      expect(event.title).to eq(title)
    end
  end

  describe 'create_new_media' do
    let!(:reviewer)       { FactoryBot.create(:user, ms_id: provider['download_reviewer']) }
    let!(:imaging_event)  { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }
    let!(:specimen)       { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }

    before do
      subject.instance_variable_set(:@slide, slide)
      subject.instance_variable_set(:@specimen, specimen)
      subject.instance_variable_set(:@imaging_event, imaging_event)
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
      allow(slide).to receive(:validate_technical_metadata).and_return(true)
    end
    it 'creates a new media' do
      media = subject.create_new_media

      # media permissions
      expect(media.edit_users).to match_array([manager.ms_id])
      expect(manager.can? :edit, media).to be(true)

      # media imaging event
      expect(media.in_works).to match_array([imaging_event])

      # media attributes
      expect(media.depositor).to eq(manager.ms_id)
      expect(media.title).to match_array(['Mcz Sc 3793 Slide 1 [Image] [Section]'])
      expect(media.remote_manifest_url).to eq("#{base_uri}info.json")
      expect(media.remote_origin_url).to eq(import_url)
      expect(media.media_type).to match_array(['Image'])
      expect(media.part).to match_array([slide_title])
      expect(media.fileset_accessibility ).to match_array(['open'])
      expect(media.x_spacing).to match_array(['0.000025'])
      expect(media.y_spacing).to match_array(['0.000025'])
      expect(media.unit).to match_array(['Cm'])
      expect(media.download_reviewer).to match_array([reviewer.ms_id])
      expect(media.agreement_uri).to match_array(provider['agreement_uri'])
      expect(media.morphosource_use_agreement_type).to match_array(provider['morphosource_use_agreement_type'])
      expect(media.required_archival_of_published_derivatives). to match_array(provider['required_archival_of_published_derivatives'])
      expect(media.permits_commercial_use).to match_array(provider['permits_commercial_use'])
      expect(media.permits_3d_use).to match_array(provider['permits_3d_use'])
      expect(media.rights_holder).to match_array(provider['rights_holder'])
      expect(media.preview_mode).to match_array(provider['preview_mode'])
      expect(media.description).to match_array(["embedding material: paraffin, part_name: histological serial section, preserve_method: histological slide, section interval: 0, section plane: transverse, section stain: Bodian and Cresyl Violet, section thickness: 15"])
      expect(media.license).to match_array(provider['license'])
      expect(media.rights_statement).to match_array(provider['rights_statement'])
      expect(media.publisher).to match_array(provider['publisher'])
      expect(media.identifier).to match_array(['3823260'])
      expect(media.related_url).to match_array(['http://mczbase.mcz.harvard.edu/media/3823260'])

      # file set
      file_set = media.file_sets.first
      expect(file_set.mime_type_of_remote).to eq('image/tiff')
      expect(file_set.depositor).to eq(manager.ms_id)
      expect(file_set.title).to eq([file_name])
      expect(file_set.label).to eq(file_name)
      expect(file_set.import_url).to eq(import_url)
    end
  end

  describe 'characterize_file' do
    let(:media)     { FactoryBot.create(:media) }
    let(:file_set)  { FactoryBot.create(:file_set)}

    before do
      Hydra::Works::AddFileToFileSet.call(file_set, File.open("#{fixture_path}/text/text.txt"), :original_file)
      media.ordered_members << file_set
      media.save!
      subject.instance_variable_set(:@slide, slide)
      subject.instance_variable_set(:@media, media)
      allow_any_instance_of(described_class).to receive(:collection).and_return(collection)
      allow(slide).to receive(:validate_technical_metadata).and_return(true)
      allow(CalculateFileSetCrc32Job).to receive(:perform_later).and_return(true)
    end

    it 'characterizes the original file' do
      expect(CalculateFileSetCrc32Job).to receive(:perform_later)
      subject.characterize_file
      file = file_set.original_file

      expect(file.aperture_value).to eq(slide.aperture_value)
      expect(file.aspect_ratio).to eq(slide.aspect_ratio)
      expect(file.bit_depth).to eq(slide.bit_depth)
      expect(file.bits_per_sample).to eq(slide.bits_per_sample)
      expect(file.byte_order).to eq(slide.byte_order)
      expect(file.capture_device).to eq(slide.capture_device)
      expect(file.channels).to eq(slide.channels)
      expect(file.color_format).to eq(slide.color_format)
      expect(file.color_map).to eq(slide.color_map)
      expect(file.color_space).to eq(slide.color_space)
      expect(file.compression).to eq(slide.compression)
      expect(file.creator).to eq(slide.creator)
      expect(file.date_created).to eq(slide.date_created)
      expect(file.date_modified).to eq(slide.date_modified)
      expect(file.file_size).to eq(slide.file_size)
      expect(file.file_title).to eq(slide.file_title)
      expect(file.file_type_extension).to eq(slide.file_type_extension)
      expect(file.focal_length).to eq(slide.focal_length)
      expect(file.format_label).to eq(slide.format_label)
      expect(file.height).to eq(slide.height)
      expect(file.modality).to eq(slide.modality)
      expect(file.orientation).to eq(slide.orientation)
      expect(file.original_checksum).to eq(slide.original_checksum)
      expect(file.photometric_interpretation).to eq(slide.photometric_interpretation)
      expect(file.pixel_spacing).to eq(slide.pixel_spacing)
      expect(file.pixel_representation).to eq(slide.pixel_representation)
      expect(file.pixel_spacing_calibration_type).to eq(slide.pixel_spacing_calibration_type)
      expect(file.profile_name).to eq(slide.profile_name)
      expect(file.profile_version).to eq(slide.profile_version)
      expect(file.sample_rate).to eq(slide.sample_rate)
      expect(file.samples_per_pixel).to eq(slide.samples_per_pixel)
      expect(file.scanning_software).to eq(slide.scanning_software)
      expect(file.secondary_capture_device_manufacturer).to eq(slide.secondary_capture_device_manufacturer)
      expect(file.series_date).to eq(slide.series_date)
      expect(file.shutter_speed).to eq(slide.shutter_speed)
      expect(file.slice_thickness).to eq(slide.slice_thickness)
      expect(file.spacing_between_slices).to eq(slide.spacing_between_slices)
      expect(file.well_formed).to eq(slide.well_formed)
      expect(file.valid).to eq(slide.valid)
      expect(file.width).to eq(slide.width)
      expect(file.file_name).to eq(slide.file_name)
      expect(file.image_type).to eq(slide.image_type)
    end
  end
end