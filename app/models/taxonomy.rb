class Taxonomy < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.work_requires_files = false

  self.indexer = TaxonomyIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [BiologicalSpecimen]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::TaxonomyMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def short_title
    ranks = [:taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies]
    title = ranks.map{|rank| self.send(rank).first}.compact.join(' ')
    return title unless title.blank?
    self.title.first
  end

  def user_supplied_title
    contributing_user_link.concat(short_title)
  end

  def contributing_user
    user = ::User.find_by_user_key(depositor)
  end


end
