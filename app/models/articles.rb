class Article < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
end