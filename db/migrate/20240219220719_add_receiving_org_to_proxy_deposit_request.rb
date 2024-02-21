class AddReceivingOrgToProxyDepositRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :proxy_deposit_requests, :receiving_organization_id, :string, index: true
  end
end
