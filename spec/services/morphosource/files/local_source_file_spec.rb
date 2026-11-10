require 'rails_helper'

RSpec.describe Morphosource::Files::LocalSourceFile do
  let(:fixture) { Rails.root.join('spec', 'fixtures', 'bunny', 'bunny.ply') }

  describe '.path' do
    context 'with an S3 StreamFile' do
      let(:file) do
        Valkyrie::StorageAdapter::StreamFile.new(
          id: Valkyrie::ID.new("shrine://#{SecureRandom.uuid}/#{SecureRandom.uuid}"),
          io: File.open(fixture, 'rb')
        )
      end

      after { FileUtils.rm_f(Dir.glob("#{file.disk_path}*")) }

      it 'returns an existing path with the original extension' do
        path = described_class.path(file, 'bunny.ply')
        expect(File.extname(path)).to eq('.ply')
        expect(File.size(path)).to eq(File.size(fixture))
      end

      it 'returns the tmp path unchanged when the original filename has no extension' do
        expect(described_class.path(file, 'bunny')).to eq(file.disk_path.to_s)
      end
    end

    context 'with a disk-backed file' do
      let(:stored_path) do
        path = Rails.root.join('tmp', "local_source_file_spec_#{SecureRandom.uuid}.ply")
        FileUtils.cp(fixture, path)
        path.to_s
      end
      let(:file) do
        Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new("disk://#{stored_path}"), io: File.open(stored_path, 'rb'))
      end

      after { FileUtils.rm_f(stored_path) }

      it 'returns the stored path without renaming it' do
        expect(described_class.path(file, 'bunny.ply')).to eq(stored_path)
        expect(File.exist?(stored_path)).to be true
      end
    end
  end
end
