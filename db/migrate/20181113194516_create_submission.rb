class CreateSubmission < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.string :institution_id
    end
  end
end
