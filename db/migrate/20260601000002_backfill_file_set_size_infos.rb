class BackfillFileSetSizeInfos < ActiveRecord::Migration[6.1]
  # Minimal inner-class stubs so the migration is self-contained.
  class FileSetSizeInfo < ApplicationRecord
    belongs_to :data_allocation, optional: true
  end

  class FundCodeMediaAssociation < ApplicationRecord
    belongs_to :fund_code, class_name: 'BackfillFileSetSizeInfos::FundCode'
  end

  class FundCode < ApplicationRecord
    has_one :data_allocation,
            class_name: 'BackfillFileSetSizeInfos::DataAllocation',
            foreign_key: :fund_code_id
  end

  class DataAllocation < ApplicationRecord; end

  PAGE_SIZE = 500

  def up
    # Fail fast if Solr is not ready. Without this guard, a slow Solr start can
    # cause the migration to complete silently with empty result sets, producing
    # FileSetSizeInfo rows with zeroed sizes. Rails would then mark the migration
    # as done and db:migrate would never re-run it. Raising here keeps the
    # migration in a re-runnable state until Solr is actually available.
    begin
      solr_check = Morphosource::SolrService.new
      solr_check.get_docs(nil, rows: 0, fq: ['has_model_ssim:Media'])
    rescue => e
      raise "BackfillFileSetSizeInfos: Solr is not ready — #{e.message}. " \
            "Re-run db:migrate once Solr is available."
    end

    # Build media_id → data_allocation_id from active fund code associations.
    # This avoids hitting Fedora per-FileSet during the migration.
    say "Building media → DataAllocation lookup from active fund code associations..."
    media_to_da = {}
    FundCodeMediaAssociation.where(active: true).find_each do |fcma|
      da_id = fcma.fund_code&.data_allocation&.id
      media_to_da[fcma.media] = da_id if da_id
    end
    say "  #{media_to_da.size} active associations found."

    # Build media_id → file_set_ids from Media Solr documents.
    say "Building file_set_id → media_id reverse map from Solr..."
    fs_to_media = {}
    solr        = Morphosource::SolrService.new
    page        = 0

    loop do
      docs = solr.get_docs(
        nil,
        rows: PAGE_SIZE,
        start: page * PAGE_SIZE,
        fq: ['has_model_ssim:Media'],
        fl: ['id', 'file_set_ids_ssim']
      )
      break if docs.empty?

      docs.each do |doc|
        Array(doc['file_set_ids_ssim']).each { |fs_id| fs_to_media[fs_id] = doc['id'] }
      end
      page += 1
    end
    say "  #{fs_to_media.size} FileSets mapped to a Media."

    # Iterate FileSets from Solr and create FileSetSizeInfo rows.
    say "Backfilling FileSetSizeInfo rows from FileSet Solr documents..."
    total   = 0
    skipped = 0
    page    = 0

    loop do
      docs = solr.get_docs(
        nil,
        rows: PAGE_SIZE,
        start: page * PAGE_SIZE,
        fq: ['has_model_ssim:FileSet'],
        fl: ['id', 'file_size_lts', 'label_tesim']
      )
      break if docs.empty?

      docs.each do |doc|
        fs_id    = doc['id']
        media_id = fs_to_media[fs_id]
        da_id    = media_id ? media_to_da[media_id] : nil

        binary_file_size = (doc['file_size_lts'] || 0).to_i
        binary_file_name = Array(doc['label_tesim']).first

        deriv_paths = Morphosource::DerivativePath.derivatives_for_reference(fs_id)
        deriv_sizes = deriv_paths.each_with_object({}) do |path, h|
          size = File.size?(path)
          h[File.basename(path)] = size if size
        end
        summed_deriv_size = deriv_sizes.values.sum

        row = FileSetSizeInfo.find_or_initialize_by(file_set_id: fs_id)
        if row.persisted?
          skipped += 1
          next
        end

        row.assign_attributes(
          media_id:                    media_id,
          data_allocation_id:          da_id,
          binary_file_size:            binary_file_size,
          binary_file_name:            binary_file_name,
          derivatives:                 deriv_sizes,
          summed_derivatives_file_size: summed_deriv_size,
          # Computed inline because this migration's stub model has no before_save callback.
          # Must match FileSetSizeInfo#compute_sum_file_size if the formula changes.
          # media_derivatives_file_size is added by migration 20260601000004 (backfilled separately).
          sum_file_size:               binary_file_size + summed_deriv_size
        )
        row.save!
        total += 1
      end

      say "  Processed #{(page + 1) * PAGE_SIZE} FileSet Solr docs... (#{total} created, #{skipped} already existed)"
      page += 1
    end

    say "Backfill complete. FileSetSizeInfo rows created: #{total}, skipped (already existed): #{skipped}."
    say "Total FileSetSizeInfo rows: #{FileSetSizeInfo.count}."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
