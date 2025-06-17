class RenameArticlesToPages < ActiveRecord::Migration[5.2]
  def change
    rename_table :articles, :pages
  end
end
