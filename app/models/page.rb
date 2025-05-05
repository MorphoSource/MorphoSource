class Page < ApplicationRecord
  enum page_type: [ :pages, :docs ]
  enum visibility: [ :unpublished, :published ]

  has_rich_text :content

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validate :slug_is_url_friendly

  def to_param
    slug
  end

  private

  def slug_is_url_friendly
    unless slug =~ /\A[a-zA-Z0-9\-]+\z/
      errors.add(:slug, "must be URL-friendly (only letters, numbers, and dashes are allowed)")
    end
  end
end