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
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
      allow(representative_presenter).to receive(:image?).and_return(image_boolean)
      allow(representative_presenter).to receive(:mesh?).and_return(mesh_boolean)
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
    let(:modality)          {['MagneticResonanceImaging']}
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

    let :work do
      Media.create(id:               id,
                   title:            title,
                   publisher:        publisher,
                   identifier:       identifier,
                   keyword:          keyword,
                   date_created:     date_created,
                   related_url:      related_url,
                   rights_statement: rights_statement,
                   agreement_uri:    agreement_uri,
                   cite_as:          cite_as,
                   funding:          funding,
                   map_type:         map_type,
                   media_type:       media_type,
                   modality:         modality,
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
                   depositor:        user)
    end

    it { is_expected.to have_attributes(title: ["M#{id}: #{title.first}"], publisher: publisher, identifier: identifier, keyword: keyword, date_created: date_created, related_url: related_url, rights_statement: rights_statement, agreement_uri: agreement_uri, cite_as: cite_as, funding: funding, map_type: map_type, media_type:  media_type, modality: modality, orientation: orientation, part: part, rights_holder: rights_holder,
    scale_bar: scale_bar, side: side, unit: unit, x_spacing: x_spacing, y_spacing: y_spacing, z_spacing: z_spacing) }

  end


  describe "Media work for showcase" do
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
    let(:modality)          {['MagneticResonanceImaging']}
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

    let :work do
      Media.create(id:               id,
                   title:            title,
                   publisher:        publisher,
                   identifier:       identifier,
                   keyword:          keyword,
                   date_created:     date_created,
                   related_url:      related_url,
                   rights_statement: rights_statement,
                   agreement_uri:    agreement_uri,
                   cite_as:          cite_as,
                   funding:          funding,
                   map_type:         map_type,
                   media_type:       media_type,
                   modality:         modality,
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
                   depositor:        user)
    end

    let(:child_id)          { '888888' }
    let(:title)             {['Media Child Work Title']}
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
    let(:modality)          {['MagneticResonanceImaging']}
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
    let(:user)              { 'test2@example.com' }

    let :child_work do
      Media.create(id:               child_id,
                   title:            title,
                   publisher:        publisher,
                   identifier:       identifier,
                   keyword:          keyword,
                   date_created:     date_created,
                   related_url:      related_url,
                   rights_statement: rights_statement,
                   agreement_uri:    agreement_uri,
                   cite_as:          cite_as,
                   funding:          funding,
                   map_type:         map_type,
                   media_type:       media_type,
                   modality:         modality,
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
                   depositor:        user,
                   work_parents_attributes: {"0"=>{"id"=>"p001", "_destroy"=>"false"}}

                    )
    end

    let(:processing_event) { ProcessingEvent.new( { id: "p001", title: ["Sample Processing Event"] } ) }
    let(:imaging_event) { ImagingEvent.new( { title: ["Sample Imaging Event"]} )}

    subject(:presenter) { described_class.new(SolrDocument.new(child_work.to_solr), nil) }

    it 'get_showcase_data' do
      #work.ordered_members << processing_event
      #processing_event.ordered_members << child_work
      subject.get_showcase_data
      expect(subject.download_permission).to eq('open')
      expect(subject.ark).to be_empty
      expect(subject.doi).to be_empty
      expect(subject.file_size).to eq("")
      expect(subject.face_count).to eq("")
      expect(subject.point_count).to eq("")
      expect(subject.data_managed_by).to be == user
      expect(subject.processing_event_count).to eq(0)
      expect(subject.raw_or_derived).to eq('Raw')

    end
  end
end
