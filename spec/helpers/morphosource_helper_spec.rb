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

  describe '#institution_object_selector' do
    let!(:institutions) do
      [ Institution.create(title: [ 'Foo' ]),
        Institution.create(title: [ 'Bar' ]) ]
    end
    let!(:physical_objects) do
      [ BiologicalSpecimen.create(title: [ 'Baz' ], institution: [ 'A' ], vouchered: [ true ]),
        BiologicalSpecimen.create(title: [ 'Boo' ], institution: [ 'B' ], vouchered: [ true ]),
        CulturalHeritageObject.create(title: [ 'Ai' ], institution: [ 'C' ], vouchered: [ true ]) ]
    end
    before do
      institutions[0].ordered_members << physical_objects[0]
      institutions[0].ordered_members << physical_objects[2]
      institutions[0].save!
      institutions[1].ordered_members << physical_objects[1]
      institutions[1].save!
    end
    it 'returns the appropriate array' do
      expect(helper.institution_object_selector(institutions[0].id)).to eq([ [ physical_objects[2].title.first,
                                                                               physical_objects[2].id ],
                                                                             [ physical_objects[0].title.first,
                                                                               physical_objects[0].id ] ])
    end
  end

  describe '#institution_selector' do
    let!(:institutions) do
      [ Institution.create(title: [ 'Foo' ]),
        Institution.create(title: [ 'Bar' ]) ]
    end
    it 'returns the appropriate array' do
      expect(helper.institution_selector).to eq([ [ institutions[1].title.first, institutions[1].id ],
                                                  [ institutions[0].title.first, institutions[0].id ] ])
    end
  end

  describe '#object_imaging_event_selector' do
    let!(:physical_objects) do
      [ BiologicalSpecimen.create(title: [ 'Baz' ], institution: [ 'A' ], vouchered: [ true ]),
        BiologicalSpecimen.create(title: [ 'Boo' ], institution: [ 'B' ], vouchered: [ true ]) ]
    end
    let!(:imaging_events) do
      [ ImagingEvent.create(title: [ 'Foo' ]), ImagingEvent.create(title: [ 'Bar' ]) ]
    end
    before do
      physical_objects[0].ordered_members << imaging_events[1]
      physical_objects[0].save!
      physical_objects[1].ordered_members << imaging_events[0]
      physical_objects[1].save!
    end
    it 'returns the appropriate array' do
      expect(helper.object_imaging_event_selector(physical_objects[0].id)).to eq([ [ imaging_events[1].title.first,
                                                                                     imaging_events[1].id ] ])
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
