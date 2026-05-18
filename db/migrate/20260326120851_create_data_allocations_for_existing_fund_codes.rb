class CreateDataAllocationsForExistingFundCodes < ActiveRecord::Migration[6.1]
  class FundCode < ApplicationRecord; end
  class DataAllocation < ApplicationRecord
    enum allocation_type: { user: 0, fund_code: 1 }
  end

  def up
    fund_code_ids_with_allocation = DataAllocation.where(allocation_type: :fund_code)
                                                  .pluck(:fund_code_id)
                                                  .compact

    fund_codes_to_backfill = FundCode.where.not(id: fund_code_ids_with_allocation)
    total = FundCode.count
    already_have = fund_code_ids_with_allocation.count
    to_create = fund_codes_to_backfill.count

    say "FundCodes total: #{total}"
    say "Already have DataAllocation: #{already_have}"
    say "To backfill: #{to_create}"

    created = 0
    fund_codes_to_backfill.find_each do |fc|
      DataAllocation.create!(
        allocation_type: :fund_code,
        fund_code_id: fc.id,
        storage_total_gb: fc.storage_total_gb
      )
      created += 1
    end

    say "DataAllocations created: #{created}"
    remaining = FundCode.joins("LEFT OUTER JOIN data_allocations ON data_allocations.fund_code_id = fund_codes.id AND data_allocations.allocation_type = 1")
                        .where(data_allocations: { id: nil }).count
    say "FundCodes still without DataAllocation: #{remaining}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
