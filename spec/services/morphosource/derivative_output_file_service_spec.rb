require 'rails_helper'

RSpec.describe Morphosource::DerivativeOutputFileService do
  let(:user) { create(:user) }

  def directives_for(id)
    path = Hyrax::DerivativePath.derivative_path_for_reference(id, 'thumbnail')
    { url: URI("file://#{path}").to_s, container: 'thumbnail_image' }
  end

  describe '.file_set_id_for' do
    it 'extracts a plain AF-style id from the derivative path' do
      expect(described_class.file_set_id_for(directives_for('000200008'))).to eq '000200008'
    end

    it 'extracts a UUID-style Postgres id from the derivative path' do
      id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'
      expect(described_class.file_set_id_for(directives_for(id))).to eq id
    end
  end

  describe '.migrated?' do
    it 'is false for an id with no Postgres row' do
      af_file_set = create(:file_set, user: user)
      expect(described_class.migrated?(af_file_set.id)).to be false
    end

    it 'is true for an id with a real Postgres row' do
      valkyrie_file_set = FactoryBot.valkyrie_create(:valkyrie_file_set, user: user)
      expect(described_class.migrated?(valkyrie_file_set.id.to_s)).to be true
    end
  end

  describe '.target_service_for / .call' do
    it 'routes an unmigrated AF FileSet to Hyrax::PersistDerivatives' do
      af_file_set = create(:file_set, user: user)
      directives = directives_for(af_file_set.id)

      expect(described_class.target_service_for(directives)).to eq Hyrax::PersistDerivatives

      expect(Hyrax::PersistDerivatives).to receive(:call).with(:stream, directives)
      expect(Hyrax::ValkyriePersistDerivatives).not_to receive(:call)
      described_class.call(:stream, directives)
    end

    it 'routes a migrated Postgres FileSet to Hyrax::ValkyriePersistDerivatives' do
      valkyrie_file_set = FactoryBot.valkyrie_create(:valkyrie_file_set, user: user)
      directives = directives_for(valkyrie_file_set.id.to_s)

      expect(described_class.target_service_for(directives)).to eq Hyrax::ValkyriePersistDerivatives

      expect(Hyrax::ValkyriePersistDerivatives).to receive(:call).with(:stream, directives)
      expect(Hyrax::PersistDerivatives).not_to receive(:call)
      described_class.call(:stream, directives)
    end
  end
end
