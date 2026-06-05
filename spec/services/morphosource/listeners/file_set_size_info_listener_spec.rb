# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::FileSetSizeInfoListener do
  subject(:listener) { described_class.new }

  let(:event_for) { ->(obj) { instance_double('Dry::Event', payload: { object: obj }) } }

  describe '#on_object_deposited' do
    context 'when the object is a FileSet' do
      let(:file_set) do
        instance_double('FileSet', id: 'fs-dep-001').tap do |fs|
          allow(fs).to receive(:is_a?).with(FileSet).and_return(true)
        end
      end

      it 'creates a FileSetSizeInfo row if one does not exist' do
        expect(FileSetSizeInfo).to receive(:find_or_create_by!).with(file_set_id: 'fs-dep-001')
        listener.on_object_deposited(event_for.call(file_set))
      end
    end

    context 'when the object is not a FileSet' do
      let(:media) do
        instance_double('Media', id: 'media-001').tap do |m|
          allow(m).to receive(:is_a?).with(FileSet).and_return(false)
        end
      end

      it 'does not create a FileSetSizeInfo row' do
        expect(FileSetSizeInfo).not_to receive(:find_or_create_by!)
        listener.on_object_deposited(event_for.call(media))
      end
    end

    context 'when FileSetSizeInfo creation raises' do
      let(:file_set) do
        instance_double('FileSet', id: 'fs-dep-002').tap do |fs|
          allow(fs).to receive(:is_a?).with(FileSet).and_return(true)
        end
      end

      it 'logs the error without re-raising' do
        allow(FileSetSizeInfo).to receive(:find_or_create_by!).and_raise(StandardError, 'DB error')
        expect(Rails.logger).to receive(:error).with(/fs-dep-002/)
        expect { listener.on_object_deposited(event_for.call(file_set)) }.not_to raise_error
      end
    end
  end

  describe '#on_object_deleted' do
    context 'when a FileSet is directly deleted (file_set_id lookup)' do
      let(:file_set) { instance_double('FileSet', id: 'fs-del-001') }
      let(:row)      { instance_double('FileSetSizeInfo') }

      before do
        allow(FileSetSizeInfo).to receive(:find_by).with(file_set_id: 'fs-del-001').and_return(row)
        allow(FileSetSizeInfo).to receive(:where).with(media_id: 'fs-del-001').and_return(double(destroy_all: []))
        allow(row).to receive(:destroy)
      end

      it 'destroys the FileSetSizeInfo row' do
        expect(row).to receive(:destroy)
        listener.on_object_deleted(event_for.call(file_set))
      end
    end

    context 'when a parent Work is deleted (media_id cleanup for orphaned FileSets)' do
      let(:media)    { instance_double('Media', id: 'media-del-001') }
      let(:relation) { double('AR relation', destroy_all: []) }

      before do
        allow(FileSetSizeInfo).to receive(:find_by).with(file_set_id: 'media-del-001').and_return(nil)
        allow(FileSetSizeInfo).to receive(:where).with(media_id: 'media-del-001').and_return(relation)
      end

      it 'destroys all FileSetSizeInfo rows by media_id' do
        expect(relation).to receive(:destroy_all)
        listener.on_object_deleted(event_for.call(media))
      end
    end

    context 'when an error occurs' do
      let(:media) { instance_double('Media', id: 'media-del-002') }

      it 'logs the error without re-raising' do
        allow(FileSetSizeInfo).to receive(:find_by).and_raise(StandardError, 'DB error')
        expect(Rails.logger).to receive(:error).with(/media-del-002/)
        expect { listener.on_object_deleted(event_for.call(media)) }.not_to raise_error
      end
    end
  end
end
