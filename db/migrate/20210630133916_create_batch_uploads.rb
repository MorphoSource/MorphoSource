class CreateBatchUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :batch_uploads do |t|

      t.timestamps
    end
  end
end
