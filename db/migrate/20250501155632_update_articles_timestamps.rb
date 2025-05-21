class UpdateArticlesTimestamps < ActiveRecord::Migration[5.2]
  def change
    # Remove the incorrect 'timestamps' string column
    remove_column :articles, :timestamps, :string

    # Add standard Rails timestamps
    add_timestamps :articles, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end
end
