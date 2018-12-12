require 'rails_helper'

RSpec.describe MorphosourceHelper, type: :helper do

  describe '#device_selector' do
    describe 'there are devices' do
      let(:device_hits) do
        [ double('ActiveFedora::SolrHit', id: 'abc'),
          double('ActiveFedora::SolrHit', id: 'def') ]
      end
      before do
        allow(device_hits[0]).to receive(:[]).with('title_ssi') { 'Bar' }
        allow(device_hits[1]).to receive(:[]).with('title_ssi') { 'Foo' }
        allow(helper).to receive(:devices) { device_hits }
      end
      it 'returns the appropriate array' do
        expect(helper.device_selector).to eq([ [ 'Bar', 'abc' ],
                                               [ 'Foo', 'def' ] ])
      end
    end
    describe 'there are no devices' do
      it 'returns an empty array' do
        expect(helper.device_selector).to match([])
      end
    end
  end

  describe '#devices' do
    describe 'there are devices' do
      let!(:devices) do
        [ Device.create(title: [ 'Foo' ]),
          Device.create(title: [ 'Bar' ]) ]
      end
      it 'returns the appropriate array' do
        results = helper.devices
        expect(results).to match([ an_instance_of(ActiveFedora::SolrHit), an_instance_of(ActiveFedora::SolrHit) ])
        expect(results.map { |result| result['title_ssi'] }).to eq([ 'Bar', 'Foo' ])
      end
    end
    describe 'there are no devices' do
      it 'returns an empty array' do
        expect(helper.institutions).to match([])
      end
    end
  end

  describe '#files_required?' do
    let(:work_class) { double }
    let(:work) { double(class: work_class) }

    around(:example) do |example|
      saved_value = Hyrax.config.work_requires_files?
      Hyrax.config.work_requires_files = hyrax_config_value
      example.run
      Hyrax.config.work_requires_files = saved_value
    end

    describe 'works require files per Hyrax config' do
      let(:hyrax_config_value) { true }

      describe 'work type requires works to have files' do
        before do
          allow(work_class).to receive(:work_requires_files?) { true }
        end
        it 'returns true' do
          expect(helper.files_required?(work)).to be true
        end
      end

      describe 'work type does not require works to have files' do
        before do
          allow(work_class).to receive(:work_requires_files?) { false }
        end
        it 'returns true' do
          expect(helper.files_required?(work)).to be true
        end
      end
    end

    describe 'works do not require files per Hyrax config' do
      let(:hyrax_config_value) { false }

      describe 'work type requires works to have files' do
        before do
          allow(work_class).to receive(:work_requires_files?) { true }
        end
        it 'returns true' do
          expect(helper.files_required?(work)).to be true
        end
      end

      describe 'work type does not require works to have files' do
        before do
          allow(work_class).to receive(:work_requires_files?) { false }
        end
        it 'returns false' do
          expect(helper.files_required?(work)).to be false
        end
      end
    end
  end

  describe '#institution_selector' do
    describe 'there are institutions' do
      let(:institution_hits) do
        [ double('ActiveFedora::SolrHit', id: 'abc'),
          double('ActiveFedora::SolrHit', id: 'def') ]
      end
      before do
        allow(institution_hits[0]).to receive(:[]).with('title_ssi') { 'Bar' }
        allow(institution_hits[1]).to receive(:[]).with('title_ssi') { 'Foo' }
        allow(helper).to receive(:institutions) { institution_hits }
      end
      it 'returns the appropriate array' do
        expect(helper.institution_selector).to eq([ [ 'Bar', 'abc' ],
                                                    [ 'Foo', 'def' ] ])
      end
    end
    describe 'there are no institutions' do
      it 'returns an empty array' do
        expect(helper.institution_selector).to match([])
      end
    end
  end

  describe '#institutions' do
    describe 'there are institutions' do
      let!(:institutions) do
        [ Institution.create(title: [ 'Foo' ]),
          Institution.create(title: [ 'Bar' ]) ]
      end
      it 'returns the appropriate array' do
        results = helper.institutions
        expect(results).to match([ an_instance_of(ActiveFedora::SolrHit), an_instance_of(ActiveFedora::SolrHit) ])
        expect(results.map { |result| result['title_ssi'] }).to eq([ 'Bar', 'Foo' ])
      end
    end
    describe 'there are no institutions' do
      it 'returns an empty array' do
        expect(helper.institutions).to match([])
      end
    end
  end

  describe '#ms_work_form_tabs' do
    let(:work) { double }
    let(:with_files_tab) { [ 'metadata', 'files', 'relationships' ] }
    let(:without_files_tab) { [ 'metadata', 'relationships' ] }

    describe 'files are required' do
      before do
        allow(helper).to receive(:files_required?) { true }
      end
      it 'includes the "files" tab' do
        expect(helper.ms_work_form_tabs(work)).to match_array(with_files_tab)
      end
    end

    describe 'files are not required' do
      before do
        allow(helper).to receive(:files_required?) { false }
      end
      it 'does not include the "files" tab' do
        expect(helper.ms_work_form_tabs(work)).to match_array(without_files_tab)
      end
    end
  end

  describe 'work type lineage helpers' do
    let(:curation_concern) { double('Morphosource::Works::Base',
                                    valid_child_concerns: valid_child_models,
                                    valid_parent_concerns: valid_parent_models) }
    let(:valid_child_models) { [ Media, ProcessingEvent ] }
    let(:valid_parent_models) { [ BiologicalSpecimen, Device ] }
    before do
      allow(curation_concern).to receive(:valid_child_concerns) { valid_child_models }
      allow(curation_concern).to receive(:valid_parent_concerns) { valid_parent_models }
    end

    describe '#find_works_autocomplete_url' do
      let(:autocomplete_url_base) { Rails.application.routes.url_helpers.qa_path + '/search/find_works' }
      let(:autocomplete_url) { "#{autocomplete_url_base}#{expected_query_string}" }
      describe 'for child relationship' do
        let(:expected_query_string) { '?type[]=Media&type[]=ProcessingEvent' }
        it 'searches for appropriate child work types' do
          expect(helper.find_works_autocomplete_url(curation_concern, :child)).to eq(autocomplete_url)
        end
      end
      describe 'for parent relationship' do
        let(:expected_query_string) { '?type[]=BiologicalSpecimen&type[]=Device' }
        it 'searches for appropriate parent work types' do
          expect(helper.find_works_autocomplete_url(curation_concern, :parent)).to eq(autocomplete_url)
        end
      end

    end

    describe '#valid_work_types_list' do
      describe 'child' do
        it 'is a string containing the expected elements' do
          expect(helper.valid_work_types_list(curation_concern, :child)).to eq('Media, Processing Event')
        end
      end
      describe 'parent' do
        it 'is a string containing the expected elements' do
          expect(helper.valid_work_types_list(curation_concern, :parent)).to eq('Biological Specimen, Device')
        end
      end
    end

  end

end
