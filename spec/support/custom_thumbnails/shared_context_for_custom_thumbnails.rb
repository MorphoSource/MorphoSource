RSpec.shared_context 'custom_thumbnails', :shared_context => :metadata do

  let(:user)                  { FactoryBot.create(:user) }
  let(:file_path)             { fixture_path + '/images/duke.png' }
  let(:uploaded_file)         { Rack::Test::UploadedFile.new(file_path) }
  let(:custom_thumbnail_path) { Hyrax::DerivativePath.derivative_path_for_reference(media.id, 'thumbnail') }
  let(:solr_doc)              { SolrDocument.find(media.id) }

  before do
    sign_in user

    # ValkyriePersistDerivatives extracts a FileSet ID from the derivative path and
    # looks it up via the Valkyrie query service. Custom thumbnails key their path by
    # media ID, not FileSet ID, so the lookup fails in tests. Stub to write directly.
    allow(Hyrax::ValkyriePersistDerivatives).to receive(:call) do |stream, directives, **|
      path = URI(directives.fetch(:url)).path
      FileUtils.mkdir_p(File.dirname(path))
      stream.rewind
      File.binwrite(path, stream.read)
    end
  end
end
