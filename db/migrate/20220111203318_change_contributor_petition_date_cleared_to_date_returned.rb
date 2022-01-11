class ChangeContributorPetitionDateClearedToDateReturned < ActiveRecord::Migration[5.2]
  def change
    rename_column :contributor_petitions, :date_cleared, :date_returned
  end
end
