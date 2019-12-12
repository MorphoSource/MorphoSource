class UpdateCartItemRequesterApprover < ActiveRecord::Migration[5.1]
  def up
    change_column :cart_items, :user_id, :string, null: false
    rename_column :cart_items, :approver, :approver_id
  end
  def down
    rename_column :cart_items, :approver_id, :approver
    change_column :cart_items, :user_id, 'integer USING CAST(user_id AS integer)'
  end
end
