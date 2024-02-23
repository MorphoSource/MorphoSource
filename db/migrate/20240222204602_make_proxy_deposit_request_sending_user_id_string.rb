class MakeProxyDepositRequestSendingUserIdString < ActiveRecord::Migration[5.2]
  def up
    change_table :proxy_deposit_requests do |t|
      t.change :sending_user_id, :string
    end
  end

  def down
    change_table :proxy_deposit_requests do |t|
      t.change :sending_user_id, :integer
    end
  end
end
