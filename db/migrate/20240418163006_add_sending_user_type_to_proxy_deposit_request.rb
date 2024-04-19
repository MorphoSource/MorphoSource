class AddSendingUserTypeToProxyDepositRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :proxy_deposit_requests, :sending_user_type, :string
  end
end
