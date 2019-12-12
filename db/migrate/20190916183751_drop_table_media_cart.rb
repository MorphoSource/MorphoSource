class DropTableMediaCart < ActiveRecord::Migration[5.1]
  def change
    drop_table :media_carts
  end
end
