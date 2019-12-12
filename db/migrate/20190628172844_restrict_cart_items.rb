class RestrictCartItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cart_items, :restricted, :boolean, default: true
    add_column :cart_items, :approver, :string, null: false
    add_column :cart_items, :date_requested, :datetime
    add_column :cart_items, :date_approved, :datetime
    add_column :cart_items, :date_denied, :datetime
    add_column :cart_items, :date_canceled, :datetime
    add_column :cart_items, :date_expired, :datetime
    add_column :cart_items, :note, :text
  end
end
