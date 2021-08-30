require 'rails_helper'
require 'support/ms_derivative_service'

RSpec.describe Morphosource::MsFileSetDerivativesService do
	let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return(FileSet.mesh_mime_types.first)
    end
  end

  subject { described_class.new(file_set) }

  it_behaves_like "a Morphosource::DerivativeService"
end