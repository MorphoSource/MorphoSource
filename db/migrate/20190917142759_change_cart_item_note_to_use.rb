class ChangeCartItemNoteToUse < ActiveRecord::Migration[5.1]
  def change
    rename_column :cart_items, :note, :use
  end
end
