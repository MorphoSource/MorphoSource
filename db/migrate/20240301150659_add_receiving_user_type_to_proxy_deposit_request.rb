class AddReceivingUserTypeToProxyDepositRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :proxy_deposit_requests, :receiving_user_type, :string
  end
end
