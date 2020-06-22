require "rails_helper"
require 'rake'

describe 'morphosource rake tasks' do

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  describe "morphosource:create_collection_types", type: :task do

    it "preloads the Rails environment" do
      expect(Rake::Task['morphosource:create_collection_types'].prerequisites).to include "environment"
    end

    it "creates team and project collection types and assigns manager and creator participants" do
      Rake::Task['morphosource:create_collection_types'].invoke

      types = Hyrax::CollectionType.all

      team = types.find{|t| t[:title] == "Team"}
      team_participants = team.collection_type_participants
      team_managers = team_participants.select{|p| p.agent_id == "admin" && p.access == "manage"}
      team_creators = team_participants.select{|p| p.agent_id == "registered" && p.access == "create"}

      project = types.find{|t| t[:title] == "Project"}
      project_participants = project.collection_type_participants
      project_managers = project_participants.select{|p| p.agent_id == "admin" && p.access == "manage"}
      project_creators = project_participants.select{|p| p.agent_id == "registered" && p.access == "create"}

      expect(team.title).to eq("Team")
      expect(team.description).to eq("Group of users belonging to the same institution, organization, department, collection, or lab. Teams can manage projects collectively.")
      expect(team.machine_id).to eq("team")
      expect(team.nestable).to be(true)
      expect(team.discoverable).to be(true)
      expect(team.sharable).to be(true)
      expect(team.allow_multiple_membership).to be(true)
      expect(team.require_membership).to be(false)
      expect(team.assigns_workflow).to be(false)
      expect(team.assigns_visibility).to be(true)
      expect(team.share_applies_to_new_works).to be(true)
      expect(team.brandable).to be(true)
      expect(team.badge_color).to eq("#FF861F")
      expect(team_participants.count).to eq(2)
      expect(team_managers.count).to eq(1)
      expect(team_creators.count).to eq(1)

      expect(project.title).to eq("Project")
      expect(project.description).to eq("Assortment of media and physical object records. Media and physical object records can belong to multiple projects. Multiple users or teams can manage projects.")
      expect(project.machine_id).to eq("project")
      expect(project.nestable).to be(true)
      expect(project.discoverable).to be(true)
      expect(project.sharable).to be(true)
      expect(project.allow_multiple_membership).to be(true)
      expect(project.require_membership).to be(false)
      expect(project.assigns_workflow).to be(false)
      expect(project.assigns_visibility).to be(true)
      expect(project.share_applies_to_new_works).to be(true)
      expect(project.brandable).to be(true)
      expect(project.badge_color).to eq("#003880")
      expect(project_participants.count).to eq(2)
      expect(project_managers.count).to eq(1)
      expect(project_creators.count).to eq(1)
    end
  end

  describe "morphosource:create_contributor_group", type: :task do
    subject { Rake::Task['morphosource:create_contributor_group'].invoke }

    it "preloads the Rails environment" do
      expect(Rake::Task['morphosource:create_contributor_group'].prerequisites).to include "environment"
    end

    context 'contributor role does not exist' do
      it "creates a contributor role" do
        expect(Role).to receive(:create).with(name: 'contributor').and_return(true)
        subject
      end
    end

    context 'contributor role already exists' do
      before do
        Role.create(name: 'contributor')
      end
      it "does not create a contributor role" do
        expect(Role).not_to receive(:create)
      end
    end
  end
end
