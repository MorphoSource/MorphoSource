class ContributorPetition < ApplicationRecord
  belongs_to :user
  serialize :user_demographics
end
