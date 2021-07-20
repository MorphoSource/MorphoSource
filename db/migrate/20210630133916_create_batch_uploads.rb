class CreateBatchSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :batch_submissions do |t|

      t.timestamps
    end
  end
end
