require 'rails_helper'

RSpec.describe MorphosourceHelper, type: :helper do

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

  describe '#find_works_autocomplete_url' do
    let(:curation_concern) { double('Morphosource::Works::Base') }
    let(:autocomplete_url_base) { Rails.application.routes.url_helpers.qa_path + '/search/find_works' }
    let(:autocomplete_url) { "#{autocomplete_url_base}#{expected_query_string}" }
    describe 'for child relationship' do
      let(:valid_child_types) { %w(Media ProcessingEvent) }
      let(:expected_query_string) { '?type[]=Media&type[]=ProcessingEvent' }
      before do
        allow(helper).to receive(:valid_lineage_types).with(curation_concern, :child) { valid_child_types }
      end
      it 'searches for appropriate child work types' do
        expect(helper.find_works_autocomplete_url(curation_concern, :child)).to eq(autocomplete_url)
      end
    end
    describe 'for parent relationship' do
      let(:valid_parent_types) { %w(BiologicalSpecimen Device) }
      let(:expected_query_string) { '?type[]=BiologicalSpecimen&type[]=Device' }
      before do
        allow(helper).to receive(:valid_lineage_types).with(curation_concern, :parent) { valid_parent_types }
      end
      it 'searches for appropriate parent work types' do
        expect(helper.find_works_autocomplete_url(curation_concern, :parent)).to eq(autocomplete_url)
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

  describe '#valid_lineage_types' do
    let(:curation_concern) { double('Morphosource::Works::Base',
                                    valid_child_concerns: valid_child_models,
                                    valid_parent_concerns: valid_parent_models) }
    let(:valid_child_models) { [ Media, ProcessingEvent ] }
    let(:valid_parent_models) { [ BiologicalSpecimen, Device ] }
    before do
      allow(curation_concern).to receive(:valid_child_concerns) { valid_child_models }
      allow(curation_concern).to receive(:valid_parent_concerns) { valid_parent_models }
    end
    describe 'child' do
      let(:expected_list) { %w(Media ProcessingEvent) }
      it 'returns the valid child concerns as an array of strings' do
        expect(helper.valid_lineage_types(curation_concern, :child)).to match_array(expected_list)
      end
    end
    describe 'parent' do
      let(:expected_list) { %w(BiologicalSpecimen Device) }
      it 'returns the valid parent concerns as an array of strings' do
        expect(helper.valid_lineage_types(curation_concern, :parent)).to match_array(expected_list)
      end
    end
  end

  describe '#valid_work_types_list' do
    let(:curation_concern) { double('Morphosource::Works::Base') }
    describe 'child' do
      let(:valid_child_types) { %w(Media ProcessingEvent) }
      before do
        allow(helper).to receive(:valid_lineage_types).with(curation_concern, :child) { valid_child_types }
      end
      it 'is a string containing the expected elements' do
        expect(helper.valid_work_types_list(curation_concern, :child)).to eq('Media, ProcessingEvent')
                                                                              .or eq('ProcessingEvent, Media')
      end
    end
    describe 'parent' do
      let(:valid_parent_types) { %w(BiologicalSpecimen Device) }
      before do
        allow(helper).to receive(:valid_lineage_types).with(curation_concern, :parent) { valid_parent_types }
      end
      it 'is a string containing the expected elements' do
        expect(helper.valid_work_types_list(curation_concern, :parent)).to eq('BiologicalSpecimen, Device')
                                                                              .or eq('Device, BiologicalSpecimen')
      end
    end
  end

end
