require 'rails_helper'

include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe SubmissionsController, type: :controller do

  include_context 'custom_thumbnails'

  let(:media)         { Media.last }
  let(:form_params)   { { media: { title: ['Test Title'] }, submission: { raw_or_derived_media: 'raw', imaging_event_id: '012345678' } } }
  let(:contributors)  { Role.create(name: 'contributor') }

  before do
    contributors.users << user
    contributors.save
    allow(subject).to receive(:assign_model_params_parents).and_return({ 'title' => ['Test Title'], 'visibility' =>
    'restricted_download' })
  end

  context 'user does not upload a custom thumbnail' do

    it 'does not create a custom thumbnail' do
      post :create, params: form_params
      expect(media.thumbnail_id).to be(nil)
    end
  end

  context 'user uploads a custom thumbnail' do

    before do
      form_params[:media][:custom_thumbnail] = uploaded_file
    end

    # remove newly created derivative
    after do
      FileUtils.rm custom_thumbnail_path
    end

    it 'creates a derivative thumbnail' do
      post :create, params: form_params
      # the derivative exists
      expect(File.exist?(custom_thumbnail_path)).to be(true)
      # solr is updated with the correct thumbnail path
      expect(solr_doc["thumbnail_path_ss"]).to eq("/downloads/#{media.id}?file=thumbnail&t=" + solr_doc["date_modified_dtsi"].to_time.to_i.to_s)
      # it updates the thumbnail id
      expect(media.reload.thumbnail_id).to eq(media.id)
    end
  end
end

RSpec.describe Hyrax::MediaController, type: :controller do

  include_context 'custom_thumbnails'

  let!(:media)        { Media.create(title: ['title'], visibility: 'open') }
  let(:file_set)      { FileSet.new }
  let(:file_set_file) { File.open(file_path) }

  let(:create_params)    { { id: media, media: { custom_thumbnail: uploaded_file, visibility: 'open'} } }

  before do
    allow(subject).to receive(:curation_concern).and_return(media)
    Hydra::Works::AddFileToFileSet.call(file_set, file_set_file, :original_file, versioning: true)
    file_set.create_derivatives(file_path)
    allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"] } )
    allow(controller.current_ability)
         .to receive(:can?)
         .with(any_args)
         .and_return true
  end

  context 'user uploads a custom thumbnail' do
    # remove newly created derivative
    after do
      FileUtils.rm custom_thumbnail_path
    end

    it 'creates a derivative thumbnail' do
      patch :update, params: create_params
      # the derivative exists
      expect(File.exist?(custom_thumbnail_path)).to be(true)
      # solr is updated with the correct thumbnail path
      expect(solr_doc["thumbnail_path_ss"]).to eq("/downloads/#{media.id}?file=thumbnail&t=" + solr_doc["date_modified_dtsi"].to_time.to_i.to_s)
      # it updates the thumbnail id
      expect(media.reload.thumbnail_id).to eq(media.id)
    end
  end

  context 'user deletes a custom thumbnail' do
    let(:delete_params)    { { id: media, media: { visibility: 'open', delete_thumbnail: "1" } } }

    before do
      media.ordered_members << file_set
      patch :update, params: create_params
    end

    it 'sets the file set derivative as the thumbnail' do
      patch :update, params: delete_params
      # it updates the thumbnail id
      expect(media.reload.thumbnail_id).to eq(file_set.id)
      # the custom derivative is removed
      expect(File.exist?(custom_thumbnail_path)).to be(false)
      # solr is updated with the correct thumbnail path
      expect(solr_doc["thumbnail_path_ss"]).to eq("/downloads/#{file_set.id}?file=thumbnail&t=" + solr_doc["date_modified_dtsi"].to_time.to_i.to_s)
      # it updates the thumbnail id
      expect(media.reload.thumbnail_id).to eq(file_set.id)
    end
  end
end
