require 'rails_helper'

RSpec.describe Morphosource::Dashboard::CollectionsHelper, type: :helper do
  include Rails.application.routes.url_helpers

  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:team)                                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project)                                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let(:media_list)                              { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: user.ms_id) }
  let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential section list'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: user.ms_id) }

  describe 'details_tab_url' do
    context 'team' do
      it { expect(helper.details_tab_url(team)).to eq(main_app.team_edit_path(team)) }
    end
    context 'project' do
      it { expect(helper.details_tab_url(project)).to eq(main_app.project_edit_path(project)) }
    end
    context 'media list' do
      it { expect(helper.details_tab_url(media_list)).to eq(main_app.media_list_edit_path(media_list)) }
    end
    context 'sequential section list' do
      it { expect(helper.details_tab_url(sequential_section_list)).to eq(main_app.sequential_section_list_edit_path(sequential_section_list)) }
    end
  end

  describe 'members_tab_url' do
    context 'team' do
      it { expect(helper.members_tab_url(team)).to eq(main_app.team_members_path(team)) }
    end
    context 'project' do
      it { expect(helper.members_tab_url(project)).to eq(main_app.project_members_path(project)) }
    end
    context 'media list' do
      it { expect(helper.members_tab_url(media_list)).to eq(main_app.media_list_members_path(media_list)) }
    end
    context 'sequential section list' do
      it { expect(helper.members_tab_url(sequential_section_list)).to eq(main_app.sequential_section_list_members_path(sequential_section_list)) }
    end
  end

  describe 'projects_tab_url' do
    it { expect(helper.projects_tab_url(team)).to eq(main_app.team_projects_path(team)) }
  end

  describe 'organization_tab_url' do
    it { expect(helper.organization_tab_url(team)).to eq(main_app.team_organization_path(team)) }
  end

  describe 'new_collection_url' do
    context 'team' do
      it { expect(helper.new_collection_url('teams')).to eq(main_app.new_team_path) }
    end
    context 'project' do
      it { expect(helper.new_collection_url('projects')).to eq(main_app.new_project_path) }
    end
    context 'media list' do
      it { expect(helper.new_collection_url('media_lists')).to eq(main_app.new_media_list_path) }
    end
    context 'sequential section list' do
      it { expect(helper.new_collection_url('sequential_section_lists')).to eq(main_app.new_sequential_section_list_path) }
    end
  end
end