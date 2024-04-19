class UpdateUserTypeOnProxyDepositRequests < ActiveRecord::Migration[5.2]
  def up
    ProxyDepositRequest.all.each do |request|
      # Update receiving_user_type
      if request.receiving_user_id.present?
        receiving_user = User.find_by(id: request.receiving_user_id) || OrganizationCollection.find_by(id: request.receiving_user_id)
        if receiving_user.present?
          request.update_column :receiving_user_type, receiving_user.model_name.to_s
        end
      end

      # Update sending_user_type
      if request.sending_user_id.present?
        sending_user = User.find_by(id: request.sending_user_id) || OrganizationCollection.find_by(id: request.sending_user_id)
        if sending_user.present?
          request.update_column :sending_user_type, sending_user.model_name.to_s
        end
      end 
    end
  end

  def down
    # Set both user_type columns to nil
    ProxyDepositRequest.all.each do |request|
      request.update_column :receiving_user_type, nil
      request.update_column :sending_user_type, nil
    end
  end
end
