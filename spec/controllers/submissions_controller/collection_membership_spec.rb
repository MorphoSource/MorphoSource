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
  let(:original_collection)     { nil }

  before do
    all_collections = (collections << original_collection).compact
    # Create collection groups and permissions
    all_collections.each do |collection|
      collection.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id)
    end
  end

  before do
    user.make_contributor
    sign_in user
    session[:submission] = {}
  end

  describe 'creating media and adding to collections' do
    context 'user is uploading a media from the dashboard' do
      context 'user is adding different numbers of collections' do
        context 'media inherit the correct permissions' do
          collection_types = [:project, :team, :organization_collection, :media_list, :sequential_section_list]

          collection_types.each do |type|
            let!(:collections)  { create_collections(type) }
            it "creates a media work with the correct number of parent #{type.to_s} collections" do
              (1..3).each do |i|
                expect_media_to_have_correct_membership_and_permissions(i)
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
            collection_types = [:project, :team, :organization_collection, :media_list, :sequential_section_list]

            collection_types.each do |type|
              let!(:collections)  { create_collections(type) }
              it "creates a media work with the correct number of parent #{type.to_s} collections" do
                (1..3).each do |i|
                  expect_media_to_have_correct_membership_and_permissions(i)
                end
              end
            end
          end
        end
      end
    end
  end

  # Create 3 collections of the given type
  def create_collections(type)
    collections = []
    (1..3).each do |i|
      collections << FactoryBot.create(type, id: "collection#{i}", depositor: user.ms_id)
    end
    collections
  end

  def expect_media_to_have_correct_membership_and_permissions(count)
    # select a portion of the created collections
    set_up_test_collections(count)
    # build expected edit, download, and read groups
    set_up_media_groups
    expect { post :create, params: params }.to change { Media.count }.by(1)
    media = Media.last
    expect(media.member_of_collections.to_a.count).to eq(count)
    expect(media.edit_groups).to match_array(@media_edit_groups)
    expect(media.download_groups).to match_array(@media_download_groups)
    expect(media.read_groups).to match_array(@media_read_groups)
  end

  def set_up_test_collections(count)
    @test_collections = Array(collections.first(count))
    # add the selected collections to the params
    @test_collections.each_with_index do |collection, index|
      collections_attributes["member_of_collections_attributes"].merge!({ "#{index}" => { "id" => collection.id, "_destroy" => "false" } })
    end
    allow(subject).to receive(:assign_model_params_parents).and_return(params["media"].merge!(collections_attributes))
  end

  def set_up_media_groups
    @media_edit_groups = ['admin']
    @media_download_groups = []
    @media_read_groups = ['public'] # media is restricted_download
    @test_collections = (@test_collections << original_collection).compact
    @test_collections.each do |collection|
      next unless collection.media_inherit_permissions? # skip lists and organizations
      @media_edit_groups += ["#{collection.id}_editors", "#{collection.id}_managers"]
      @media_download_groups += ["#{collection.id}_downloaders"]
      @media_read_groups += ["#{collection.id}_viewers"]
    end
  end
end
