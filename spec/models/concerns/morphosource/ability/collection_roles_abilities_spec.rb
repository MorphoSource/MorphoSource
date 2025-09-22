# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Hyrax::Ability::CollectionAbility' do

  let(:collection_depositor)  { FactoryBot.create(:contributor) }
  let(:registered_user)       { FactoryBot.create(:registered_user) }
  let(:contributor)           { FactoryBot.create(:contributor) }
  let(:admin)                 { FactoryBot.create(:admin) }

  let(:manager)               { User.create(email: 'manager@email.com', password: 'password') }
  let(:editor)                { User.create(email: 'editor@email.com', password: 'password') }
  let(:depositor)             { User.create(email: 'depositor@email.com', password: 'password') }
  let(:downloader)            { User.create(email: 'downloader@email.com', password: 'password') }
  let(:viewer)                { User.create(email: 'viewer@email.com', password: 'password') }

  let(:collection_types)      { [:project, :team, :media_list, :sequential_section_list, :organization_collection] }

  let!(:collection)           { FactoryBot.create(collection_type, id: "#{collection_type}1", depositor: collection_depositor.ms_id, visibility: 'restricted' ) }

  before do
    [manager, editor, depositor].each(&:make_contributor)
    collection.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
  end

  context 'Team' do
    let(:collection_type)     { :team }

    it 'grants the appropriate abilities to collection members' do
      check_initial_collection_abilities

      # add users to collection groups
      collection.managers << manager
      collection.editors << editor
      collection.depositors << depositor
      collection.downloaders << downloader
      collection.viewers << viewer

      # manager
      # can edit, edit_works, deposit, download_works, read
      # can NOT manage
      ability = Ability.new(manager.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(true)
      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(true)

      # editor
      # can edit_works, deposit, download_works, read
      # can NOT manage, edit
      ability = Ability.new(editor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # depositor
      # can deposit, read
      # can NOT manage, edit, edit_works, download_works
      ability = Ability.new(depositor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # downloader
      # can download_works, read
      # can NOT manage, edit, edit_works, deposit
      ability = Ability.new(downloader.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # viewer
      # can read
      # can NOT manage, edit, edit_works, deposit, download_works
      ability = Ability.new(viewer.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)
    end
  end

  context 'Project' do
    let(:collection_type) { :project }

    it 'grants the appropriate abilities to collection members' do
      check_initial_collection_abilities

      # add users to collection groups
      collection.managers << manager
      collection.editors << editor
      collection.depositors << depositor
      collection.downloaders << downloader
      collection.viewers << viewer

      # manager
      # can edit, edit_works, deposit, download_works, read
      # can NOT manage
      ability = Ability.new(manager.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(true)

      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(true)

      # editor
      # can edit_works, deposit, download_works, read
      # can NOT manage, edit
      ability = Ability.new(editor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # depositor
      # can deposit, read
      # can NOT manage, edit, edit_works, download_works
      ability = Ability.new(depositor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # downloader
      # can download_works, read
      # can NOT manage, edit, edit_works, deposit
      ability = Ability.new(downloader.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # viewer
      # can read
      # can NOT manage, edit, edit_works, deposit, download_works
      ability = Ability.new(viewer.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)
    end
  end

  context 'Organization' do
    let(:collection_type) { :organization_collection }

    it 'grants the appropriate abilities to collection members' do
      check_initial_collection_abilities

      # add users to collection groups
      collection.managers << manager
      collection.editors << editor
      collection.depositors << depositor
      collection.downloaders << downloader
      collection.viewers << viewer

      # manager
      # can edit, edit_works, deposit, download_works, read, destroy
      # can NOT manage
      ability = Ability.new(manager.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(true)
      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      # TODO:
      # expect(ability.can? :destroy, collection).to be(false)

      # editor
      # can edit_works, deposit, download_works, read, destroy
      # can NOT manage, edit
      ability = Ability.new(editor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(true)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # depositor
      # can deposit, read
      # can NOT manage, edit, edit_works, download_works, destroy
      ability = Ability.new(depositor.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # downloader
      # can download_works, read
      # can NOT manage, edit, edit_works, deposit, destroy
      ability = Ability.new(downloader.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(true)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)

      # viewer
      # can read
      # can NOT manage, edit, edit_works, deposit, download_works, destroy
      ability = Ability.new(viewer.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)
    end
  end

  context 'Media List' do
    let(:collection_type)     { :media_list }

    it 'grants the appropriate abilities to collection members' do
      check_initial_collection_abilities

      # add users to collection groups
      collection.managers << manager
      collection.viewers << viewer

      # manager
      # can edit, edit_works, deposit, download_works, read
      # can NOT manage
      ability = Ability.new(manager.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(true)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(true)

      # viewer
      # can read
      # can NOT manage, edit, edit_works, deposit, download_works
      ability = Ability.new(viewer.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)
    end
  end

  context 'Sequential Section List' do
    let(:collection_type)     { :sequential_section_list }

    it 'grants the appropriate abilities to collection members' do
      check_initial_collection_abilities

      # add users to collection groups
      collection.managers << manager
      collection.viewers << viewer

      # manager
      # can edit, edit_works, deposit, download_works, read
      # can NOT manage
      ability = Ability.new(manager.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(true)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(true)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(true)

      # viewer
      # can read
      # can NOT manage, edit, edit_works, deposit, download_works
      ability = Ability.new(viewer.reload)
      expect(ability.can? :manage, collection).to be(false)
      expect(ability.can? :edit, collection).to be(false)
      expect(ability.can? :edit_works, collection).to be(false)
      expect(ability.can? :deposit, collection).to be(false)
      expect(ability.can? :download_works, collection).to be(false)
      expect(ability.can? :read, collection).to be(true)
      expect(ability.can? :destroy, collection).to be(false)
    end
  end

  # Before users are added to collection groups, check that only admins have collection abilities
  def check_initial_collection_abilities
    # admin
    ability = Ability.new(admin)
    expect(ability.can? :manage, collection).to be(true)
    expect(ability.can? :edit, collection).to be(true)
    expect(ability.can? :edit_works, collection).to be(true)
    expect(ability.can? :deposit, collection).to be(true)
    expect(ability.can? :download_works, collection).to be(true)
    expect(ability.can? :read, collection).to be(true)
    expect(ability.can? :view, collection).to be(true)
    expect(ability.can? :destroy, collection).to be(true)

    # manager
    ability = Ability.new(manager)
    expect(ability.can? :manage, collection).to be(false)
    expect(ability.can? :edit, collection).to be(false)
    expect(ability.can? :edit_works, collection).to be(false)
    expect(ability.can? :deposit, collection).to be(false)
    expect(ability.can? :download_works, collection).to be(false)
    expect(ability.can? :read, collection).to be(false)
    expect(ability.can? :destroy, collection).to be(false)

    # editor
    ability = Ability.new(editor)
    expect(ability.can? :manage, collection).to be(false)
    expect(ability.can? :edit, collection).to be(false)
    expect(ability.can? :edit_works, collection).to be(false)
    expect(ability.can? :deposit, collection).to be(false)
    expect(ability.can? :download_works, collection).to be(false)
    expect(ability.can? :read, collection).to be(false)
    expect(ability.can? :destroy, collection).to be(false)

    # depositor
    ability = Ability.new(depositor)
    expect(ability.can? :manage, collection).to be(false)
    expect(ability.can? :edit, collection).to be(false)
    expect(ability.can? :edit_works, collection).to be(false)
    expect(ability.can? :deposit, collection).to be(false)
    expect(ability.can? :download_works, collection).to be(false)
    expect(ability.can? :read, collection).to be(false)
    expect(ability.can? :destroy, collection).to be(false)

    # downloader
    ability = Ability.new(downloader)
    expect(ability.can? :manage, collection).to be(false)
    expect(ability.can? :edit, collection).to be(false)
    expect(ability.can? :edit_works, collection).to be(false)
    expect(ability.can? :deposit, collection).to be(false)
    expect(ability.can? :download_works, collection).to be(false)
    expect(ability.can? :read, collection).to be(false)
    expect(ability.can? :destroy, collection).to be(false)
  end
end