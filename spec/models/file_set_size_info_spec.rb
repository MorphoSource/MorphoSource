require 'rails_helper'

RSpec.describe FileSetSizeInfo do
  it { should belong_to(:data_allocation) }

  it 'allows nil data_allocation_id (optional association)' do
    row = FileSetSizeInfo.new(file_set_id: 'fs-opt')
    expect(row).to be_valid
  end

  let(:da) { DataAllocation.create!(allocation_type: :user) }

  describe '.upsert_for_file_set' do
    context 'when no row exists yet' do
      it 'creates a new row' do
        expect { FileSetSizeInfo.upsert_for_file_set('fs-001', binary_file_size: 1000) }
          .to change(FileSetSizeInfo, :count).by(1)
      end

      it 'sets the given attrs on the new row' do
        row = FileSetSizeInfo.upsert_for_file_set('fs-001', binary_file_size: 1000, binary_file_name: 'scan.ply')
        expect(row.binary_file_size).to eq(1000)
        expect(row.binary_file_name).to eq('scan.ply')
      end
    end

    context 'when a row already exists' do
      before { FileSetSizeInfo.create!(file_set_id: 'fs-001', binary_file_size: 500) }

      it 'updates the existing row without creating a duplicate' do
        expect { FileSetSizeInfo.upsert_for_file_set('fs-001', binary_file_size: 2000) }
          .not_to change(FileSetSizeInfo, :count)
      end

      it 'overwrites the given attrs' do
        FileSetSizeInfo.upsert_for_file_set('fs-001', binary_file_size: 2000)
        expect(FileSetSizeInfo.find_by(file_set_id: 'fs-001').binary_file_size).to eq(2000)
      end
    end

    context 'when a concurrent insert causes RecordNotUnique' do
      it 'retries by finding and updating the winning row' do
        # Simulate race: first save! raises RecordNotUnique, then find_by! returns the existing row
        FileSetSizeInfo.create!(file_set_id: 'fs-race', binary_file_size: 100)
        call_count = 0
        allow_any_instance_of(FileSetSizeInfo).to receive(:save!).and_wrap_original do |method, *args|
          call_count += 1
          if call_count == 1
            raise ActiveRecord::RecordNotUnique, 'Duplicate entry'
          else
            method.call(*args)
          end
        end

        row = FileSetSizeInfo.upsert_for_file_set('fs-race', binary_file_size: 5000)
        expect(row.binary_file_size).to eq(5000)
        expect(FileSetSizeInfo.where(file_set_id: 'fs-race').count).to eq(1)
      end
    end

    context 'when file_set argument responds to id' do
      let(:file_set) { instance_double('FileSet', id: 'fs-002') }

      it 'uses file_set.id.to_s as the key' do
        FileSetSizeInfo.upsert_for_file_set(file_set, binary_file_size: 999)
        expect(FileSetSizeInfo.find_by(file_set_id: 'fs-002')).to be_present
      end
    end
  end

  describe 'before_save: compute_sum_file_size' do
    it 'sets sum_file_size = binary_file_size + summed_derivatives_file_size on create' do
      row = FileSetSizeInfo.create!(file_set_id: 'fs-003', binary_file_size: 1000, summed_derivatives_file_size: 500)
      expect(row.sum_file_size).to eq(1500)
    end

    it 'recomputes sum_file_size on update of binary_file_size' do
      row = FileSetSizeInfo.create!(file_set_id: 'fs-004', binary_file_size: 1000, summed_derivatives_file_size: 200)
      row.update!(binary_file_size: 3000)
      expect(row.sum_file_size).to eq(3200)
    end

    it 'recomputes sum_file_size on update of summed_derivatives_file_size' do
      row = FileSetSizeInfo.create!(file_set_id: 'fs-005', binary_file_size: 1000, summed_derivatives_file_size: 200)
      row.update!(summed_derivatives_file_size: 800)
      expect(row.sum_file_size).to eq(1800)
    end

    it 'preserves existing summed_derivatives_file_size when only binary_file_size is updated via upsert' do
      FileSetSizeInfo.create!(file_set_id: 'fs-006', binary_file_size: 1000, summed_derivatives_file_size: 500)
      FileSetSizeInfo.upsert_for_file_set('fs-006', binary_file_size: 2000)
      row = FileSetSizeInfo.find_by(file_set_id: 'fs-006')
      expect(row.summed_derivatives_file_size).to eq(500)
      expect(row.sum_file_size).to eq(2500)
    end

    it 'includes media_derivatives_file_size in sum_file_size on create' do
      row = FileSetSizeInfo.create!(
        file_set_id:                 'fs-007',
        binary_file_size:            1000,
        summed_derivatives_file_size: 500,
        media_derivatives_file_size: 200
      )
      expect(row.sum_file_size).to eq(1700)
    end

    it 'recomputes sum_file_size on update of media_derivatives_file_size' do
      row = FileSetSizeInfo.create!(file_set_id: 'fs-008', binary_file_size: 1000, summed_derivatives_file_size: 200)
      row.update!(media_derivatives_file_size: 300)
      expect(row.sum_file_size).to eq(1500)
    end
  end

  describe '.update_media_derivatives' do
    let!(:row) do
      FileSetSizeInfo.create!(
        file_set_id:                 'fs-upd-001',
        media_id:                    'media-upd-001',
        binary_file_size:            5000,
        summed_derivatives_file_size: 1000
      )
    end

    it 'updates media_derivatives_file_size on matching rows' do
      FileSetSizeInfo.update_media_derivatives('media-upd-001', 750)
      expect(row.reload.media_derivatives_file_size).to eq(750)
    end

    it 'recomputes sum_file_size to include the new media derivative size' do
      FileSetSizeInfo.update_media_derivatives('media-upd-001', 750)
      expect(row.reload.sum_file_size).to eq(6750)
    end

    it 'is a no-op when no rows match media_id' do
      expect { FileSetSizeInfo.update_media_derivatives('nonexistent', 999) }.not_to raise_error
    end
  end
end
