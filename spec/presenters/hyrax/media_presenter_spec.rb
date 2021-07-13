# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::MediaPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:user_key) { 'a_user_key' }
  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => ['foo', 'bar'],
      "human_readable_type_tesim" => ["Generic Work"],
      "has_model_ssim" => ["GenericWork"],
      "date_created_tesim" => ['an unformatted date'],
      "depositor_tesim" => user_key }
  end
  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }


  describe '#universal_viewer?' do
    let(:id_present) { false }
    let(:representative_presenter) { double('representative', present?: false) }
    let(:image_boolean) { false }
    let(:mesh_boolean) { false }
    let(:volume_boolean) { false }
    let(:iiif_enabled) { true }
    let(:file_set_presenter) { Hyrax::MediaFileSetPresenter.new(solr_document, ability) }
    let(:file_set_presenters) { [file_set_presenter] }
    let(:read_permission) { true }

    before do
      allow(presenter).to receive(:representative_id).and_return(id_present)
      allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
      allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
      allow(file_set_presenter).to receive(:image?).and_return(true)
      allow(file_set_presenter).to receive(:mesh?).and_return(true)
      allow(file_set_presenter).to receive(:volume?).and_return(true)
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
      allow(representative_presenter).to receive(:image?).and_return(image_boolean)
      allow(representative_presenter).to receive(:mesh?).and_return(mesh_boolean)
      allow(representative_presenter).to receive(:volume?).and_return(volume_boolean)
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
    end

    subject { presenter.universal_viewer? }

    context 'with no representative_id' do
      it { is_expected.to be false }
    end

    context 'with no representative_presenter' do
      let(:id_present) { true }

      it { is_expected.to be false }
    end

    context 'with non-image and non-mesh representative_presenter' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { false }
      let(:mesh_boolean) { false }

      it { is_expected.to be false }
    end

    context 'with IIIF image server turned off' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:iiif_enabled) { false }

      it { is_expected.to be false }
    end

    context 'with representative image and IIIF turned on' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:mesh_boolean) { false }
      let(:iiif_enabled) { true }

      it { is_expected.to be true }

      context "when the user doesn't have permission to view the image" do
        let(:read_permission) { false }

        it { is_expected.to be false }
      end
    end

    context 'with representative mesh and IIIF turned on' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { false }
      let(:mesh_boolean) { true }
      let(:iiif_enabled) { true }

      it { is_expected.to be true }

      context "when the user doesn't have permission to view the image" do
        let(:read_permission) { false }

        it { is_expected.to be false }
      end
    end
  end

  describe "media member presenter" do
    subject { presenter }

    it "is a Hyrax::MediaMemberPresenterFactory object" do
      expect(presenter.send(:member_presenter_factory)).to be_a Hyrax::MediaMemberPresenterFactory
    end
  end

  describe "sample Media work" do
    subject(:presenter) { described_class.new(SolrDocument.new(work.to_solr), nil) }

    let(:id)                { 'aaa' }
    let(:title)             {['Media Work Title']}
    let(:publisher)         {['Random House']}
    let(:identifier)        {['123ABC']}
    let(:keyword)           {['purple']}
    let(:date_created)      {['January 1, 1977']}
    let(:related_url)       {['www.aaa.com']}
    let(:rights_statement)  {['In Copyright - EU Orphan Work']}
    let(:agreement_uri)     {['www.zzz.com']}
    let(:cite_as)           {['Media Work Citation']}
    let(:funding)           {['NSF']}
    let(:map_type)          {['Color Map']}
    let(:media_type)        {['PhotogrammetryImageStack']}
    let(:orientation)       {['Media Orientation']}
    let(:part)              {['Part 7']}
    let(:rights_holder)     {['Martha Stewart']}
    let(:scale_bar)         {['Type: Scale_bar_target_type, Distance: Scale_bar_distance, Units: Scale_bar_units']}
    let(:side)              {['left']}
    let(:unit)              {['inch']}
    let(:x_spacing)         {['5']}
    let(:y_spacing)         {['7']}
    let(:z_spacing)         {['9']}
    let(:visibility)        { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    let(:user)              { 'test@example.com' }
    let(:fileset_accessibility) {['open']}
    let(:permits_3d_use) {['3DPrintingPermitted']}
    let(:permits_commercial_use) {['CommercialUsePermitted']}
    let(:morphosource_use_agreement_type) {['Permissive']}
    let(:required_archival_of_published_derivatives) {['OnAnyRepository']}

    let :work do
      Media.create(id:               id,
                   title:            title,
                   publisher:        publisher,
                   identifier:       identifier,
                   keyword:          keyword,
                   date_created:     date_created,
                   related_url:      related_url,
                   rights_statement: rights_statement,
                   permits_3d_use:   permits_3d_use,
                   permits_commercial_use: permits_commercial_use,
                   morphosource_use_agreement_type: morphosource_use_agreement_type,
                   required_archival_of_published_derivatives: required_archival_of_published_derivatives,
                   agreement_uri:    agreement_uri,
                   cite_as:          cite_as,
                   funding:          funding,
                   map_type:         map_type,
                   media_type:       media_type,
                   orientation:      orientation,
                   part:             part,
                   rights_holder:    rights_holder,
                   scale_bar:        scale_bar,
                   side:             side,
                   unit:             unit,
                   x_spacing:        x_spacing,
                   y_spacing:        y_spacing,
                   z_spacing:        z_spacing,
                   visibility:       visibility,
                   fileset_accessibility: fileset_accessibility,
                   depositor:        user)
    end


    it {
      is_expected.to have_attributes(title: ["#{title.first}"], publisher: publisher, identifier: identifier, keyword: keyword, date_created: date_created, related_url: related_url, rights_statement: rights_statement, agreement_uri: agreement_uri, cite_as: cite_as, funding: funding, map_type: map_type, media_type:  media_type, orientation: orientation, part: part, rights_holder: rights_holder,
    scale_bar: scale_bar, side: side, unit: unit, x_spacing: x_spacing, y_spacing: y_spacing, z_spacing: z_spacing)
    }

    context '#is_published?' do
      subject { presenter.is_published? }
      it {
        presenter.get_showcase_data
        is_expected.to be true
      }
    end

    context 'preview_mode default value' do
      subject { presenter.preview_mode.first }
      it {
        is_expected.to eq 'Interactive/Embeddable'
      }
    end

    context '#preview_in_3D?' do
      subject { presenter.preview_in_3D? }
      it {
        is_expected.to be true
      }
    end

  end

  describe '#has_child_media?' do
    let(:empty_list) { [] }
    let(:media_list) { ['1','2'] }

    subject { presenter.has_child_media? }

    context 'with no child media' do
      before do
        presenter.instance_variable_set(:@child_media_id_list, empty_list)
      end
      it { is_expected.to be false }
    end

    context 'with child media' do
      before do
        presenter.instance_variable_set(:@child_media_id_list, media_list)
      end
      it { is_expected.to be true }
    end
  end

  describe 'ordered_processing_events' do
    let(:media)  { Media.create(id: presenter.id, title: ['media']) }
    let(:parent_media)  { Media.create(title: ['parent_media']) }
    let(:grandparent_media)  { Media.create(title: ['grandparent_media']) }
    let(:great_grandparent_media)  { Media.create(title: ['great_grandparent_media']) }

    let(:processing_event_1)  { ProcessingEvent.create(title: ['processing event 1']) }
    let(:processing_event_2)  { ProcessingEvent.create(title: ['processing event 2']) }
    let(:processing_event_3)  { ProcessingEvent.create(title: ['processing event 3']) }
    let(:processing_event_4)  { ProcessingEvent.create(title: ['processing event 4']) }

    subject { presenter.send(:ordered_processing_events, direct_parent_id) }

    before do
      presenter.instance_variable_set(:@media, media)
      allow(presenter).to receive(:top_parent_media_id).and_return(direct_parent_id)
    end

    context 'raw media only' do
      let(:direct_parent_id)  { nil }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'derived media only' do
      let(:direct_parent_id)    { nil }

      before do
        processing_event_1.ordered_members << media
        processing_event_1.save!
      end

      it 'returns the only processing event' do
        expect(subject).to eq([processing_event_1])
      end
    end

    context '2nd level derived media' do
      let(:direct_parent_id) { parent_media.id }

      context 'direct parent is raw' do
        before do
          parent_media.ordered_members << processing_event_1
          processing_event_1.ordered_members << media
          [processing_event_1, parent_media].each(&:save!)
        end

        it 'returns one processing event' do
          expect(subject).to eq([processing_event_1])
        end
      end

      context 'direct parent is derived' do
        before do
          processing_event_1.ordered_members << parent_media
          parent_media.ordered_members << processing_event_2
          processing_event_2.ordered_members << media
          [processing_event_1, parent_media, processing_event_2].each(&:save!)
        end

        it 'returns the two processing events in order' do
          expect(subject).to eq([processing_event_1, processing_event_2])
        end
      end
    end

    context 'fourth level derived media' do
      let(:direct_parent_id) { great_grandparent_media.id }

      context 'direct parent is raw' do
        before do
          great_grandparent_media.ordered_members << processing_event_1
          processing_event_1.ordered_members << grandparent_media
          grandparent_media.ordered_members << processing_event_2
          processing_event_2.ordered_members << parent_media
          parent_media.ordered_members << processing_event_3
          processing_event_3.ordered_members << media
          [great_grandparent_media, processing_event_1, grandparent_media, processing_event_2, parent_media, processing_event_3].each(&:save!)
        end

        it 'returns two processing events in order' do
          expect(subject).to eq([processing_event_1, processing_event_2, processing_event_3])
        end
      end

      context 'direct parent is derived' do
        before do
          processing_event_1.ordered_members << great_grandparent_media
          great_grandparent_media.ordered_members << processing_event_2
          processing_event_2.ordered_members << grandparent_media
          grandparent_media.ordered_members << processing_event_3
          processing_event_3.ordered_members << parent_media
          parent_media.ordered_members << processing_event_4
          processing_event_4.ordered_members << media
          [processing_event_1, great_grandparent_media, processing_event_2, grandparent_media, processing_event_3, parent_media, processing_event_4].each(&:save!)
        end

        it 'returns the four processing events in order' do
          expect(subject).to eq([processing_event_1, processing_event_2, processing_event_3, processing_event_4])
        end
      end
    end
    context 'third level derived media' do
      let(:direct_parent_id) { grandparent_media.id }

      context 'direct parent is raw' do
        before do
          grandparent_media.ordered_members << processing_event_1
          processing_event_1.ordered_members << parent_media
          parent_media.ordered_members << processing_event_2
          processing_event_2.ordered_members << media
          [grandparent_media, processing_event_1, parent_media, processing_event_2].each(&:save!)
        end

        it 'returns two processing events in order' do
          expect(subject).to eq([processing_event_1, processing_event_2])
        end
      end

      context 'direct parent is derived' do
        before do
          processing_event_1.ordered_members << grandparent_media
          grandparent_media.ordered_members << processing_event_2
          processing_event_2.ordered_members << parent_media
          parent_media.ordered_members << processing_event_3
          processing_event_3.ordered_members << media
          [processing_event_1, grandparent_media, processing_event_2, parent_media, processing_event_3].each(&:save!)
        end

        it 'returns the three processing events in order' do
          expect(subject).to eq([processing_event_1, processing_event_2, processing_event_3])
        end
      end
    end
  end

  describe 'processing_activity_hash' do
    # typical string
    let(:step1_string)  { "Step: 1, Type: Test Type, Software: Test Software, Description: Test Description"}
    let(:step1_hash)    { {"Description"=>"Test Description", "Software"=>"Test Software", "Step"=>"1", "Type"=>"Test Type"} }

    # text contains colons
    let(:step2_string)  { "Step: 2, Type: Transform: Rotation, Software: Test: Test, Description: Test: Test"}
    let(:step2_hash)    { {"Description"=>"Test: Test", "Software"=>"Test: Test", "Step"=>"2", "Type"=>"Transform: Rotation"} }

    # text contains match headings
    let(:step3_string)  { "Step: 3, Type: Type, Software: , Description: Type, Description: , Description: Description"}
    let(:step3_hash)    { {"Description"=>"Type, Description: , Description: Description", "Software"=>"", "Step"=>"3", "Type"=>"Type"} }

    # headings are empty
    let(:step4_string)  { "Step: 4, Type: , Software: , Description: "}
    let(:step4_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"4", "Type"=>""} }

    # the string is empty
    let(:step5_string)  { "" }
    let(:step5_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"", "Type"=>""} }

    # the string is nil
    let(:step6_string)  { nil }
    let(:step6_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"", "Type"=>""} }

    it 'creates a hash of processing activity components' do
      expect(presenter.send(:processing_activity_hash, step1_string)).to eq(step1_hash)
      expect(presenter.send(:processing_activity_hash, step2_string)).to eq(step2_hash)
      expect(presenter.send(:processing_activity_hash, step3_string)).to eq(step3_hash)
      expect(presenter.send(:processing_activity_hash, step4_string)).to eq(step4_hash)
      expect(presenter.send(:processing_activity_hash, step5_string)).to eq(step5_hash)
      expect(presenter.send(:processing_activity_hash, step6_string)).to eq(step6_hash)
    end
  end
end
