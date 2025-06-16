class AddCommunicationPreferenceToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :communication_preference, :integer, default: 0, null: false
  end
end
