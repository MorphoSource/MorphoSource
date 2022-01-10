class CreateContributorPetitions < ActiveRecord::Migration[5.2]
  def change
    create_table :contributor_petitions do |t|
      t.references :user, index: true, foreign_key: true
      t.text :reason
      t.string :user_affiliation
      t.string :user_department
      t.text :user_demographics
      t.string :user_demographics_other
      t.string :user_advisor
      t.string :contribution_amount
      t.boolean :terms_agree
      t.boolean :decision_required
      t.string :decision_state
      t.text :decision_message
      t.string :decision_by
      t.datetime :date_approved
      t.datetime :date_cleared
      t.datetime :date_denied

      t.timestamps
    end
  end
end
