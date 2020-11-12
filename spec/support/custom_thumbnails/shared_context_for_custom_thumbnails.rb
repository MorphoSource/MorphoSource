RSpec.shared_context 'custom_thumbnails', :shared_context => :metadata do

  let(:user)                  { FactoryBot.create(:user) }
  let(:file_path)             { fixture_path + '/images/duke.png' }
  let(:uploaded_file)         { Rack::Test::UploadedFile.new(file_path) }
  let(:custom_thumbnail_path) { Hyrax::DerivativePath.derivative_path_for_reference(media.id, 'thumbnail') }
  let(:solr_doc)              { SolrDocument.find(media.id) }

  before do
    sign_in user
  end
end
