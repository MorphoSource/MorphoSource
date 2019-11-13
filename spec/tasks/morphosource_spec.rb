require "rails_helper"
require 'rake'

  describe "morphosource:create_collection_types", type: :task do

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    it "preloads the Rails environment" do
      expect(Rake::Task['morphosource:create_collection_types'].prerequisites).to include "environment"
    end

    it "creates team and project collection types" do
      Rake::Task['morphosource:create_collection_types'].invoke
      expect(Hyrax::CollectionType.count).to eq(2)

      types = Hyrax::CollectionType.all
      team = types.find{|t| t[:title] == "Team"}
      project = types.find{|t| t[:title] == "Project"}

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
    end
  end
