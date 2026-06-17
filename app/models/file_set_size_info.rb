class FileSetSizeInfo < ApplicationRecord
  belongs_to :data_allocation, optional: true

  before_save :compute_sum_file_size

  # Finds or initializes the FileSetSizeInfo row for the given FileSet, merges
  # attrs, and saves. file_set may be a FileSet instance or a file_set_id string.
  def self.upsert_for_file_set(file_set, attrs = {})
    fs_id = file_set.respond_to?(:id) ? file_set.id.to_s : file_set.to_s
    row = find_or_initialize_by(file_set_id: fs_id)
    row.assign_attributes(attrs)
    row.save!
    row
  rescue ActiveRecord::RecordNotUnique
    # Concurrent insert won the race; reload and update the winning row
    row = find_by!(file_set_id: fs_id)
    row.update!(attrs)
    row
  end

  private

  # sum_file_size is always the authoritative total; recomputed on every save
  # so callers only need to update binary_file_size or summed_derivatives_file_size.
  def compute_sum_file_size
    self.sum_file_size = (binary_file_size || 0) + (summed_derivatives_file_size || 0)
  end
end
