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

  describe '#physical_object_selector' do
    describe 'institution present' do
      describe 'institution has objects' do
        let(:object_docs) do
          [ double('SolrDocument', id: 'def', sortable_title: 'Ai'),
            double('SolrDocument', id: 'abc', sortable_title: 'Baz') ]
        end
        before do
          allow(helper).to receive(:institution_objects).with('zyx') { object_docs }
        end
        it 'returns the appropriate array' do
          expect(helper.physical_object_selector('zyx')).to eq([ [ 'Ai', 'def' ],
                                                                    [ 'Baz', 'abc' ] ])
        end
      end
      describe 'institution has no objects' do
        before do
          allow(helper).to receive(:institution_objects).with('zyx') { [] }
        end
        it 'returns an empty array' do
          expect(helper.physical_object_selector('zyx')).to match([])
        end
      end
    end
    describe 'institution not present' do

    end
  end

  describe '#institution_objects' do
    describe 'institution has objects' do
      let!(:institutions) do
        [ Institution.create(title: [ 'Foo' ]),
          Institution.create(title: [ 'Bar' ]) ]
      end
      let!(:physical_objects) do
        [ BiologicalSpecimen.create(title: [ 'Baz' ], vouchered: [ true ]),
          BiologicalSpecimen.create(title: [ 'Boo' ], vouchered: [ true ]),
          CulturalHeritageObject.create(title: [ 'Ai' ], vouchered: [ true ]) ]
      end
      before do
        institutions[0].ordered_members << physical_objects[0]
        institutions[0].ordered_members << physical_objects[2]
        institutions[0].save!
        institutions[1].ordered_members << physical_objects[1]
        institutions[1].save!
      end
      it 'returns the appropriate array' do
        results = helper.institution_objects(institutions[0].id)
        expect(results).to match([ an_instance_of(SolrDocument), an_instance_of(SolrDocument) ])
        expect(results.map { |result| result.sortable_title }).to eq([ 'Ai', 'Baz' ])
      end
    end
    describe 'institution has no objects' do
      let!(:institution) { Institution.create(title: [ 'Foo' ]) }
      it 'returns an empty array' do
        expect(helper.institution_objects(institution.id)).to match([])
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

  describe '#object_imaging_event_selector' do
    describe 'object has imaging events' do
      let(:imaging_event_docs) do
        [ double('SolrDocument', id: 'def', sortable_title: 'Bar') ]
      end
      before do
        allow(helper).to receive(:object_imaging_events).with('zyx') { imaging_event_docs }
      end
      it 'returns the appropriate array' do
        expect(helper.object_imaging_event_selector('zyx')).to eq([ [ 'Bar', 'def' ] ])
      end
    end
    describe 'object has no imaging events' do
      before do
        allow(helper).to receive(:object_imaging_events).with('zyx') { [] }
      end
      it 'returns an empty array' do
        expect(helper.object_imaging_events('zyx')).to match([])
      end
    end
  end

  describe '#object_imaging_events' do
    describe 'object has imaging events' do
      let!(:physical_objects) do
        [ BiologicalSpecimen.create(title: [ 'Baz' ], vouchered: [ true ]),
          BiologicalSpecimen.create(title: [ 'Boo' ], vouchered: [ true ]) ]
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
        results = helper.object_imaging_events(physical_objects[0].id)
        expect(results).to match([ an_instance_of(SolrDocument) ])
        expect(results.map { |result| result.sortable_title }).to eq([ 'Bar' ])
      end
    end
    describe 'object has no imaging events' do
      let!(:physical_object) { BiologicalSpecimen.create(title: [ 'Baz' ], vouchered: [ true ]) }
      it 'returns an empty array' do
        expect(helper.object_imaging_events(physical_object.id)).to match([])
      end
    end

  end

  describe '#physical_objects' do
    describe 'objects exist' do
      let!(:physical_objects) do
        [ BiologicalSpecimen.create(title: [ 'Baz' ], vouchered: [ true ]),
          BiologicalSpecimen.create(title: [ 'Boo' ], vouchered: [ true ]),
          CulturalHeritageObject.create(title: [ 'Ai' ], vouchered: [ true ]) ]
      end
      it 'returns the appropriate array' do
        results = helper.physical_objects
        expect(results).to match([ an_instance_of(ActiveFedora::SolrHit), an_instance_of(ActiveFedora::SolrHit),
                                   an_instance_of(ActiveFedora::SolrHit) ])
        expect(results.map { |result| result['title_ssi'] }).to eq([ 'Ai', 'Baz', 'Boo' ])
      end
    end
    describe 'no objects exist' do
      it 'returns an empty array' do
        expect(helper.physical_objects).to match([])
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
