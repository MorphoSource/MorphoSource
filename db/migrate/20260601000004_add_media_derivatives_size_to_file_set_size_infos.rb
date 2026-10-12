class AddMediaDerivativesSizeToFileSetSizeInfos < ActiveRecord::Migration[6.1]
  # Minimal stub so the migration is self-contained.
  class FileSetSizeInfo < ApplicationRecord; end

  def up
    add_column :file_set_size_infos, :media_derivatives_file_size, :bigint,
               default: 0, null: false

    # Backfill: for any existing row that has a media_id, glob the media-level
    # derivative directory on disk (where custom thumbnails are stored) and record
    # the current total size. Uses update_columns (no callback) so sum_file_size
    # must be computed inline — keep in sync with FileSetSizeInfo#compute_sum_file_size.
    FileSetSizeInfo.where.not(media_id: nil).find_each do |row|
      deriv_size = Morphosource::DerivativePath.derivatives_for_reference(row.media_id)
                     .map { |p| File.size?(p) }.compact.sum
      next if deriv_size.zero?

      row.update_columns(
        media_derivatives_file_size: deriv_size,
        sum_file_size: row.binary_file_size + row.summed_derivatives_file_size + deriv_size
      )
    end
  end

  def down
    remove_column :file_set_size_infos, :media_derivatives_file_size
  end
end
