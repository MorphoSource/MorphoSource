class AddTypeToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :page_type, :integer, default: 0
  end
end
