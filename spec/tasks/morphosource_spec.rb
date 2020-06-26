require "rails_helper"
require 'rake'

describe 'morphosource rake tasks' do
  let(:setup)                     { Rake::Task['morphosource:setup'] }
  let(:create_admin_set)          { Rake::Task['hyrax:default_admin_set:create'] }
  let(:create_collection_types)   { Rake::Task['morphosource:create_collection_types'] }
  let(:create_admin_role)         { Rake::Task['morphosource:create_admin_role'] }
  let(:create_contributor_role)   { Rake::Task['morphosource:create_contributor_role'] }
  let(:create_development_users)  { Rake::Task['morphosource:create_development_users'] }
  let(:create_production_users)   { Rake::Task['morphosource:create_production_users'] }
  let(:tasks)                     { [setup, create_admin_set, create_collection_types, create_admin_role, create_contributor_role, create_development_users, create_production_users] }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    tasks.each(&:reenable)
  end

  describe "morphosource:create_collection_types", type: :task do
    let(:team_settings)     { Morphosource::CollectionTypes::Teams::SETTINGS }
    let(:project_settings)  { Morphosource::CollectionTypes::Projects::SETTINGS }
    let(:types)  { Hyrax::CollectionType.all }
    let(:team_type)         { types.find{|t| t[:title] == "Team"} }
    let(:project_type)      { types.find{|t| t[:title] == "Project"} }
    let(:type_settings)     { [ { type: team_type, settings: team_settings }, { type: project_type, settings: project_settings } ] }

    it 'creates collection types' do
      expect { create_collection_types.invoke }.to change { Hyrax::CollectionType.count }.by(2)
    end

    it 'assigns the correct attribute values' do
      create_collection_types.invoke

      type_settings.each do |t|
        type = t[:type]
        settings = t[:settings]

        expect(type.title).to eq(settings[:title])
        expect(type.description).to eq(settings[:description])
        expect(type.machine_id).to eq(settings[:machine_id])
        expect(type.nestable).to be(settings[:nestable])
        expect(type.discoverable).to be(settings[:discoverable])
        expect(type.sharable).to be(settings[:sharable])
        expect(type.allow_multiple_membership).to be(settings[:allow_multiple_membership])
        expect(type.require_membership).to be(settings[:require_membership])
        expect(type.assigns_workflow).to be(settings[:assigns_workflow])
        expect(type.assigns_visibility).to be(settings[:assigns_visibility])
        expect(type.share_applies_to_new_works).to be(settings[:share_applies_to_new_works])
        expect(type.brandable).to be(settings[:brandable])
        expect(type.badge_color).to eq(settings[:badge_color])
      end
    end

    it "assigns manager and creator participants" do
      create_collection_types.invoke

      [team_type, project_type].each do |type|
        participants = type.collection_type_participants
        managers = participants.select{|p| p.agent_id == 'admin' && p.access == 'manage'}
        creators = participants.select{|p| p.agent_id == 'registered' && p.access == 'create'}

        expect(participants.count).to eq(2)
        expect(managers.count).to eq(1)
        expect(creators.count).to eq(1)
      end
    end
  end

  describe "morphosource:create_contributor_role", type: :task do

    context 'contributor role does not exist' do
      it "creates a contributor role" do
        expect(Role).to receive(:create).with(name: 'contributor').and_return(true)
        create_contributor_role.invoke
      end
    end

    context 'contributor role already exists' do
      before do
        Role.create(name: 'contributor')
      end
      it "does not create a contributor role" do
        expect(Role).not_to receive(:create)
        create_contributor_role.invoke
      end
    end
  end

  describe 'create_development_users', type: :task do
    let(:defaults)              { Morphosource::Users::Defaults }
    let(:admin_defaults)        { defaults::ADMIN }
    let(:contributor_defaults)  { defaults::CONTRIBUTOR }
    let(:registered_defaults)   { defaults::REGISTERED }
    let(:admin)                 { User.find_by(email: admin_defaults[:email]) }
    let(:contributor)           { User.find_by(email: contributor_defaults[:email]) }
    let(:registered)            { User.find_by(email: registered_defaults[:email]) }
    let(:user_settings)         { [
      { user: admin, settings: admin_defaults },
      { user: contributor, settings: contributor_defaults },
      { user: registered, settings: registered_defaults } ] }

    it 'creates admin, contributor, and registered users' do
      expect { create_development_users.invoke }.to change { User.count }.by(3)
    end

    it 'assigns the new users appropriate roles' do
      create_development_users.invoke
      expect(admin.admin?).to be(true)
      expect(contributor.contributor?).to be(true)
      expect(registered.registered?).to be(true)
    end

    it 'assigns the new users the correct values' do
      create_development_users.invoke

      user_settings.each do |u|
        user = u[:user]
        defaults = u[:settings]

        expect(user.email).to eq(defaults[:email])
        expect(user.guest).to eq(defaults[:guest])
        expect(user.facebook_handle).to eq(defaults[:facebook_handle])
        expect(user.twitter_handle).to eq(defaults[:twitter_handle])
        expect(user.display_name).to eq(defaults[:display_name])
        expect(user.address).to eq(defaults[:address])
        expect(user.department).to eq(defaults[:department])
        expect(user.website).to eq(defaults[:website])
        expect(user.affiliation).to eq(defaults[:affiliation])
        expect(user.telephone).to eq(defaults[:telephone])
        expect(user.orcid).to eq(defaults[:orcid])
        expect(user.state).to eq(defaults[:state])
        expect(user.country).to eq(defaults[:country])
        expect(user.postal_code).to eq(defaults[:postal_code])
        expect(user.terms_read).to eq(defaults[:terms_read])
        expect(user.ms1_user).to eq(defaults[:ms1_user])
      end
    end
  end

  describe "morphosource:create_admin_role", type: :task do

    context 'admin role does not exist' do
      it "creates an admin role" do
        expect(Role).to receive(:create).with(name: 'admin').and_return(true)
        create_admin_role.invoke
      end
    end

    context 'admin role already exists' do
      before do
        Role.create(name: 'admin')
      end
      it "does not create a contributor role" do
        expect(Role).not_to receive(:create)
        create_admin_role.invoke
      end
    end
  end

  describe 'setup' do

    context 'when development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'calls the appropriate tasks' do
        expect(create_admin_set).to receive(:invoke)
        expect(create_collection_types).to receive(:invoke)
        expect(create_admin_role).to receive(:invoke)
        expect(create_contributor_role).to receive(:invoke)
        setup.invoke
      end
    end
  end
end
