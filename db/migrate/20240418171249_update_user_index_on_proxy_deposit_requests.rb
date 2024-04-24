class UpdateUserIndexOnProxyDepositRequests < ActiveRecord::Migration[5.2]
  def change
    # remove previous indices
    remove_index :proxy_deposit_requests, name: "index_proxy_deposit_requests_on_receiving_user_id"
    remove_index :proxy_deposit_requests, name: "index_proxy_deposit_requests_on_sending_user_id"

    # add new indices
    add_index :proxy_deposit_requests, 
      [:receiving_user_type, :receiving_user_id], 
      name: "index_requests_on_receiver_type_id"
    add_index :proxy_deposit_requests, 
      [:sending_user_type, :sending_user_id], 
      name: "index_requests_on_sender_type_id"
  end
end
