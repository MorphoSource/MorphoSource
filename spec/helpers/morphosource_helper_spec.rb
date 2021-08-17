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
    let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
    let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid) }

    let(:user)  { double('user') }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      helper.instance_variable_set(:@collection, team)
    end

    context 'user is an admin' do
      before do
        allow(user).to receive(:admin?).and_return(true)
      end
      it 'calls Morphosource::SolrService' do
        expect(Morphosource::SolrService).to receive_message_chain(:new, :get_docs).with('human_readable_type_sim:Project NOT member_of_collection_ids_ssim:*')
        helper.eligible_child_projects
      end
    end

    context 'user is not an admin' do
      before do
        allow(user).to receive(:admin?).and_return(false)
      end
      it 'calls Morphosource::Collections::NestedCollectionQueryService' do
        expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:available_project_collections).with(parent: team, scope: controller)
        helper.eligible_child_projects
      end
    end
  end

  describe 'grouped_access_list' do
    let(:owner)             { User.create(email: 'owner@email.com', password: 'password') }
    let(:depositor)         { User.create(email: 'depositor@email.com', password: 'password') }
    let(:editor)            { User.create(email: 'editor@email.com', password: 'password') }
    let(:viewer)            { User.create(email: 'viewer@email.com', password: 'password') }
    let(:group_viewer)      { User.create(email: 'group_viewer@email.com', password: 'password') }
    let(:group_downloader)  { User.create(email: 'group_downloader@email.com', password: 'password') }
    let(:group_editor)      { User.create(email: 'group_editor@email.com', password: 'password') }
    let(:group_manager)     { User.create(email: 'group_manager@email.com', password: 'password') }

    let(:viewer_group)      { Role.create(name: 'viewer_group') }
    let(:downloader_group)  { Role.create(name: 'downloader_group') }
    let(:editor_group)      { Role.create(name: 'editor_group') }
    let(:manager_group)     { Role.create(name: 'manager_group') }

    let(:groups)            { [viewer_group, downloader_group, editor_group, manager_group] }

    before do
      viewer_group.users << group_viewer
      downloader_group.users << group_downloader
      editor_group.users << group_editor
      manager_group.users << group_manager
      groups.each(&:save)
      media.edit_users += [depositor, editor]
      media.read_users += [viewer]
      media.edit_groups += [editor_group, manager_group]
      media.read_groups += [viewer_group, downloader_group]
      media.save!
    end

    context 'media has an owner and a depositor' do
      let!(:media) { Media.create(title: ['title'], depositor: depositor.ms_id, owner: owner.ms_id) }

      before do
        media.edit_users += [owner]
        media.save!
      end

      it 'returns a list of users and access' do
        helper.simple_form_for media, url: '' do |f|
          individual_list, group_list = helper.grouped_access_list(f)
          # owner is data manager, so is excluded
          # depositor is included in individual list
          expect(individual_list.map{|p| [p.object.agent_name, p.object.access]}).to match_array([[depositor.ms_id, "edit"],[editor.ms_id, "edit"], [viewer.ms_id, "read"]])
          expect(group_list).to eq({"downloader"=>"#{group_downloader.email} (group)", "editor"=>"#{group_editor.email} (group)", "manager"=>"#{group_manager.email} (group)", "viewer"=>"#{group_viewer.email} (group)"})
        end
      end
    end

    context 'media has only a depositor' do
      let(:media) { Media.create(title: ['title'], depositor: depositor.ms_id) }

      it 'returns a list of users and access' do
        helper.simple_form_for media, url: '' do |f|
          individual_list, group_list = helper.grouped_access_list(f)
          # depositor is data manager and is excluded
          expect(individual_list.map{|p| [p.object.agent_name, p.object.access]}).to match_array([[editor.ms_id, "edit"], [viewer.ms_id, "read"]])
          expect(group_list).to eq({"downloader"=>"#{group_downloader.email} (group)", "editor"=>"#{group_editor.email} (group)", "manager"=>"#{group_manager.email} (group)", "viewer"=>"#{group_viewer.email} (group)"})
        end
      end
    end
  end
end
