class AddSftpShareToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sftp_share, :string
  end
end
