require 'rails_helper'

RSpec.describe Morphosource::Ms1Controller, type: :controller do

  describe 'MS1 media group should redirect to media' do
    let!(:work)         { Media.create(title: ['test title'], legacy_media_group_id: ['56789']) }
    it 'should redirect to media with the MS1 media group ID' do
      get :media_group, params: { id: '56789' }
      expect(response).to redirect_to "/media/#{work.id}"
    end
  end

  scenario 'MS1 media file id should redirect to media' do
    get :media, params: { id: '1234' }
    expect(response).to redirect_to "/media/000001234"
  end

  scenario 'MS1 specimen detail should redirect to biological_specimens' do
    get :biological_specimens, params: { id: '1234' }
    expect(response).to redirect_to "/biological_specimens/0000S1234"
  end

  scenario 'MS1 project detail should redirect to projects' do
    get :projects, params: { id: '1234' }
    expect(response).to redirect_to "/projects/0000C1234"
  end

  describe '#media_thumbnail' do
    it 'redirects from MS1 thumbnail image to MS2 thumbnail route successfully' do
      # full URL would be /media/morphosource/images/3/1/3/87744_ms_media_files_media_31329_large.jpg 
      get :media_thumbnail, params: { prefix: '3/1/3', file: '87744_ms_media_files_media_31329_large.jpg' }
      expect(response).to redirect_to "/media/000031329/thumbnail"
    end

    it 'redirect to root with 404 message if file name is malformed' do
      get :media_thumbnail, params: { prefix: '3/1/3', file: 'image.jpg' }
      expect(response).to redirect_to(root_path)
    end
  end
end
