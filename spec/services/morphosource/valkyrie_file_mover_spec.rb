require 'rails_helper'

RSpec.describe Morphosource::ValkyrieFileMover do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:source) { File.join(tmp_dir, 'source.txt') }
  let(:dest) { File.join(tmp_dir, 'dest.txt') }

  before { File.write(source, 'hello world') }
  after { FileUtils.rm_rf(tmp_dir) }

  describe '.call' do
    it 'hard-links the destination to the source (same inode, no extra disk usage)' do
      described_class.call(source, dest)

      expect(File.read(dest)).to eq 'hello world'
      expect(File.stat(dest).ino).to eq File.stat(source).ino
      expect(File.stat(dest).nlink).to eq 2
    end

    it 'falls back to a real copy when the link would cross devices' do
      allow(File).to receive(:link).with(source, dest).and_raise(Errno::EXDEV)

      described_class.call(source, dest)

      expect(File.read(dest)).to eq 'hello world'
      expect(File.stat(dest).ino).not_to eq File.stat(source).ino
    end

    it 'falls back to a real copy when the source does not support hard links (ENOENT)' do
      allow(File).to receive(:link).with(source, dest).and_raise(Errno::ENOENT)

      described_class.call(source, dest)

      expect(File.read(dest)).to eq 'hello world'
    end
  end
end
