# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Riiif::ValkyrieFileResolver do
  subject(:resolver) { described_class.new(fallback_resolver: fallback_resolver) }

  let(:fallback_resolver) { double('fallback_resolver', find: :fallback_file) }
  let(:file_set) do
    FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'images/ms.jpg')
  end
  let(:file_metadata) { Hyrax.custom_queries.find_original_file(file_set: file_set) }

  def iiif_id(file_set_id, file_id)
    CGI.escape("#{file_set_id}/files/#{file_id}")
  end

  it 'resolves a native Valkyrie file (UUID FileSet id) from storage' do
    file = resolver.find(iiif_id(file_set.id, file_metadata.id))

    expect(file).to be_a(Riiif::File)
    expect(File.size(file.path)).to eq(File.size(Rails.root.join('spec', 'fixtures', 'images', 'ms.jpg')))
    expect(fallback_resolver).not_to have_received(:find)
  end

  it 'resolves a migrated file (9-digit FileSet id) from storage' do
    file = resolver.find(iiif_id('000999001', file_metadata.id))

    expect(file).to be_a(Riiif::File)
    expect(fallback_resolver).not_to have_received(:find)
  end

  it 'falls back to Fedora for a legacy AF file not in Postgres' do
    id = iiif_id('000999001', SecureRandom.uuid)

    expect(resolver.find(id)).to eq(:fallback_file)
    expect(fallback_resolver).to have_received(:find).with(id)
  end

  it 'falls back to Fedora for a half-migrated file whose bytes are still in Fedora' do
    half_migrated = Hyrax.persister.save(
      resource: Hyrax::FileMetadata.new(file_identifier: Valkyrie::ID.new("fedora://000999001/files/#{SecureRandom.uuid}"),
                                        file_set_id: file_set.id)
    )
    id = iiif_id('000999001', half_migrated.id)

    expect(resolver.find(id)).to eq(:fallback_file)
    expect(fallback_resolver).to have_received(:find).with(id)
  end
end
