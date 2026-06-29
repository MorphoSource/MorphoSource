class UpdateDataAllocationStorageJob < Hyrax::ApplicationJob
  queue_as :default

  # Stay safely below Solr's default maxBooleanClauses limit (1024 in Solr ≤ 8.x)
  BATCH_SIZE = 1_000

  def perform(data_allocation)
    raise "this type of data allocation is not yet supported" if data_allocation.user?
    raise "fund_code is nil for fund_code-type DataAllocation #{data_allocation.id}" unless data_allocation.fund_code

    media_ids = data_allocation.fund_code.fund_code_media_associations.where(active: true).pluck(:media)

    total_bytes = 0
    if media_ids.any?
      solr = Morphosource::SolrService.new
      media_ids.each_slice(BATCH_SIZE) do |batch|
        docs = solr.get_docs(nil, {
          fq: ["id:(#{batch.join(' OR ')})"],
          fl: ['id', 'all_files_file_size_lts']
        })
        total_bytes += docs.map { |doc| doc['all_files_file_size_lts'] }.compact.sum
      end
    end

    # Convert bytes to binary gigabytes (1 GiB = 2^30 bytes)
    gb_total = total_bytes / 1_073_741_824.0
    data_allocation.update!(storage_current_gb: gb_total)
  end
end
