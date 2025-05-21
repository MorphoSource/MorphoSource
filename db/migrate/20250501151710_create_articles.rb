class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :slug
      t.string :title
      t.integer :visibility, default: 0
      t.string :timestamps
    end
    add_index :articles, :slug, unique: true
  end
end
