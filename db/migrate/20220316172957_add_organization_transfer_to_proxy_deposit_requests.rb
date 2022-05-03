class AddOrganizationTransferToProxyDepositRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :proxy_deposit_requests, :organization_transfer, :boolean, :default => false
  end
end
