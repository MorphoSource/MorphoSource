require 'rails_helper'

# Tests adding media to collections through the submissions controller
# See also app/actors/hyrax/actors/collections_membership_actor.rb and
# app/actors/hyrax/actors/apply_permission_template_actor.rb

RSpec.describe SubmissionsController, type: :controller do

  TYPES_APPLYING_PERMISSIONS = [:project, :team]
  TYPES_NOT_APPLYING_PERMISSIONS = [:organization_collection, :media_list, :sequential_section_list]

  let(:user)                    { FactoryBot.build(:confirmed_user) }
  let!(:contributors)           { Role.create(name: 'contributor') }
  let(:params)                  { { "media" => {
                                      "title" => ['Test Media Title'],
                                      "visibility" => 'restricted_download'
                                    },
                                    "submission" => {
                                      "raw_or_derived_media" => 'raw',
                                      "imaging_event_id" => '012345678',
                                    }
                                  }
                                }

  let(:collections_attributes)  { { "member_of_collections_attributes" => {} } }
  let(:collections)             { create_collections(collection_count, collection_type) }
  let(:media)                   { Media.first }
  let(:original_collection)     { nil }

  # Sets up variable amount of projects for testing
  # 'projects' is defined in test contexts below
  before do
    # Create collection groups and permissions for variable number of projects.
    collections.each do |collection|
      collection.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id)
    end
    # Add projects to collections_attributes hash
    collections.each_with_index do |collection, index|
      collections_attributes["member_of_collections_attributes"].merge!({ "#{index}" => { "id" => collection.id, "_destroy" => "false" } })
    end
    allow(subject).to receive(:assign_model_params_parents).and_return(params["media"].merge!(collections_attributes))
  end

  before do
    user.make_contributor
    sign_in user
    session[:submission] = {}
  end

  describe 'creating media and adding to collections' do
    context 'user is uploading a media from the dashboard' do
      context 'user is adding different numbers of collections' do
        context 'media inherit permissions' do
          # Test with 0, 1, 2, and 3 collections
          TYPES_APPLYING_PERMISSIONS.each do |type|
            (0..3).each do |i|
              context "user is adding #{i} #{type}s" do
                let(:collection_count) { i }
                let(:collection_type)  { type }
                it 'creates a media work with the correct number of parent collections' do
                  expect_media_to_have_correct_membership_and_permissions
                end
              end
            end
          end
        end
        context 'media do not inherit permissions' do
          # Test with 0, 1, 2, and 3 collections
          TYPES_NOT_APPLYING_PERMISSIONS.each do |type|
            (0..3).each do |i|
              context "user is adding #{ i } #{ type }s" do
                let(:collection_count) { i }
                let(:collection_type)  { type }
                it 'creates a media work with the correct number of parent collections' do
                  expect_media_to_have_correct_membership_and_permissions
                end
              end
            end
          end
        end
      end
      context 'user is uploading a media to a collection' do
        let(:original_collection)  { FactoryBot.create(:project, id: "original_project", depositor: user.ms_id) }
        before do
          params["media"]["collection_id"] = original_collection.id
        end
        context 'user is adding different numbers of collections in addition to the original collection' do
          context 'media inherit permissions' do
            # Test with 0 - 4 collections
            TYPES_APPLYING_PERMISSIONS.each do |type|
              (0..3).each do |i|
                context "user is adding #{i} #{type}s" do
                  let(:collection_count) { i }
                  let(:collection_type)  { type }
                  it 'creates a media work with the correct number of parent collections' do
                    expect_media_to_have_correct_membership_and_permissions
                  end
                end
              end
            end
          end
          context 'media do not inherit permissions' do
            # Test with 0 - 3 collections
            TYPES_NOT_APPLYING_PERMISSIONS.each do |type|
              (0..3).each do |i|
                context "user is adding #{i} #{type}s" do
                  let(:collection_count) { i }
                  let(:collection_type)  { type }
                  it 'creates a media work with the correct number of parent collections' do
                    expect_media_to_have_correct_membership_and_permissions
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def create_collections(count, type)

    collections = []
    (count+1).times do |i|
      next if i == 0 # Skip creating a '0' collection
      collections << FactoryBot.create(type, id: "collection#{i}", depositor: user.ms_id)
    end
    # If user is uploading to a project, add that project to the list
    (collections << original_collection).compact
  end

  # media are added to collections and inherit permissions from those collections if the collection type is applies permissions
  def expect_media_to_have_correct_membership_and_permissions
    media_edit_groups = ['admin']
    media_download_groups = []
    media_read_groups = ['public']
    expect(Media.count).to eq(0)
    post :create, params: params
    expect(Media.count).to eq(1)
    expect(media.member_of_collections.to_a.count).to eq(collections.count)
    collections.each do |collection|
      next unless collection.media_inherit_permissions?
      media_edit_groups += ["#{collection.id}_editors", "#{collection.id}_managers"]
      media_download_groups += ["#{collection.id}_downloaders"]
      media_read_groups += ["#{collection.id}_viewers"]
    end
    expect(media.edit_groups).to match_array(media_edit_groups)
    expect(media.download_groups).to match_array(media_download_groups)
    expect(media.read_groups).to match_array(media_read_groups)
  end
end
