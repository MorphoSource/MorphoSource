require 'rails_helper'

RSpec.describe MorphosourceHelper, type: :helper do

  describe 'render_extra(extras, id, variable)' do
    let(:id) {'abc'}
    let(:extras) { [{'id' => id, 'source_of_result' => 'team_project', 'team_project_title' => 'test title'}] }
    let(:variable) {'source_of_result'}
    it 'returns the value from the variable' do
      expect(helper.render_extra(extras, id, variable)).to eq('team_project')
    end
  end

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
        expect(helper.organizations).to match([])
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

  describe '#organization_selector' do
    describe 'there are organizations' do
      let(:organization_hits) do
        [ double('ActiveFedora::SolrHit', id: 'abc'),
          double('ActiveFedora::SolrHit', id: 'def') ]
      end
      before do
        allow(organization_hits[0]).to receive(:[]).with('title_ssi') { 'Bar' }
        allow(organization_hits[1]).to receive(:[]).with('title_ssi') { 'Foo' }
        allow(helper).to receive(:organizations) { organization_hits }
      end
      it 'returns the appropriate array' do
        expect(helper.organization_selector).to eq([ [ 'Bar', 'abc' ],
                                                    [ 'Foo', 'def' ] ])
      end
    end
    describe 'there are no organizations' do
      it 'returns an empty array' do
        expect(helper.organization_selector).to match([])
      end
    end
  end

  describe '#organizations' do
    describe 'there are organizations' do
      let!(:organizations) do
        [ Organization.create(title: [ 'Foo' ]),
          Organization.create(title: [ 'Bar' ]) ]
      end
      it 'returns the appropriate array' do
        results = helper.organizations
        expect(results).to match([ an_instance_of(ActiveFedora::SolrHit), an_instance_of(ActiveFedora::SolrHit) ])
        expect(results.map { |result| result['title_ssi'] }).to eq([ 'Bar', 'Foo' ])
      end
    end
    describe 'there are no organizations' do
      it 'returns an empty array' do
        expect(helper.organizations).to match([])
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
        let(:expected_query_string) { '?type[]=Media&type[]=ProcessingEvent&id=NA' }
        it 'searches for appropriate child work types' do
          expect(helper.find_works_autocomplete_url(curation_concern, :child)).to eq(autocomplete_url)
        end
      end
      describe 'for parent relationship' do
        let(:expected_query_string) { '?type[]=BiologicalSpecimen&type[]=Device&id=NA' }
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

    describe '#render_publication_status_badge, render_view_link_publication_status_badge' do
      let(:document)  { SolrDocument.new(media.to_solr) }
      let(:media)     { Media.create(id: 'aaa', title: ["Test Media Work"], visibility: 'open', fileset_visibility: [''])}
      let(:model)     { Hyrax::SolrDocumentBehavior::ModelWrapper.new(Media,media.id) }

      context 'media and files are open' do
        before do
          media.fileset_accessibility = ["open"]
        end

        it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-success\">Open Download</span></a>") }

        it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-success\">Open Download</span></a>") }
      end

      context 'media is open, files are restricted' do
        before do
          media.fileset_accessibility = ["restricted_download"]
        end

        it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-info\">Restricted Download</span></a>") }

        it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-info\">Restricted Download</span></a>") }
      end

      context 'media is open, files are preview only' do
        before do
          media.fileset_accessibility = ["preview_only"]
        end

        it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-info\">No Download</span></a>") }

        it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-info\">No Download</span></a>") }
      end

      context 'media is open, files are hidden' do
        before do
          media.fileset_visibility = ["restricted"]
          media.fileset_accessibility = ['hidden']
        end

        it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-info\">Hidden</span></a>") }

        it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-info\">Hidden</span></a>") }
      end

      context 'media and files are both private' do
        before do
          media.visibility = "restricted"
          media.fileset_accessibility = ["private"]
        end

        it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-danger\">Private</span></a>") }

        it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-danger\">Private</span></a>") }
      end

      # disable tests for leases and embargoes for now since MS doesn't use them.

      # context 'media and files are under embargo' do
      #   let(:embargo) { double("Embargo")}
      #
      #   before do
      #     media.visibility = "restricted"
      #     media.fileset_accessibility = ['']
      #     allow(embargo).to receive(:active?).and_return(true)
      #     allow(media).to receive(:embargo).and_return(embargo)
      #   end
      #
      #   it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-warning\">Embargo</span></a>") }
      #
      #   it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-warning\">Embargo</span></a>") }
      # end

  #     context 'media and files are under a lease' do
  #       let(:lease) { double("Lease")}
  #
  #       before do
  #         media.fileset_accessibility = [""]
  #         allow(lease).to receive(:active?).and_return(true)
  #         allow(media).to receive(:lease).and_return(lease)
  #       end
  #
  #       it { expect(helper.render_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa/edit#share\"><span class=\"label label-warning\">Lease</span></a>") }
  #
  #       it { expect(helper.render_view_link_publication_status_badge(document)).to eq("<a id=\"permission_aaa\" class=\"visibility-link\" href=\"/concern/media/aaa\"><span class=\"label label-warning\">Lease</span></a>") }
  #     end
    end
  end

  describe 'eligible_child_projects' do
    let(:depositor)               { User.create(email: 'depositor@email.com', password: 'password') }
    let(:user)                    { User.create(email: 'email@email.com', password: 'password') }
    let(:ability)                 { Ability.new(user) }
    let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
    let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: depositor.ms_id) }
    let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
    let!(:projectA)               { Collection.create(title: ['ProjectA'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
    let(:projectB)                { Collection.create(title: ['ProjectB'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
    let(:projectC)                { Collection.create(title: ['ProjectC'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
    let(:projectD)                { Collection.create(title: ['ProjectD'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }
    let(:projects)                { [projectA, projectB, projectC, projectD] }

    before do
      projects.each do |project|
        project.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
      end
      projectD.member_of_collections << team
      projectB.edit_users += [user]
      projectC.managers << user
      projectC.managers_group.save
      projectD.managers << user
      projectD.managers_group.save
      projects.each(&:save!)
      user.reload
      allow(helper).to receive(:current_ability).and_return(ability)
    end

    it 'returns projects the user can edit, that are not child projects of another team' do
      # user can't edit projectA, user can edit project D, but it is already a subcollection
      expect(helper.eligible_child_projects).to match_array([projectB,projectC])
    end

  end
end
