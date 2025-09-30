# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource TaxonomyResource`
class TaxonomyResource < Hyrax::Work
  include Hyrax::Schema(:taxonomy_resource)

  delegate :download_groups, :download_groups=,
           :download_users,  :download_users=, to: :permission_manager

  def short_title
    ranks = [:taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies]
    title = ranks.map { |rank| self.send(rank).first }.compact.join(' ')
    return title unless title.blank?
    self.title.first
  end

  def contributing_user
    user = ::User.find_by_user_key(depositor)
  end

  def gbif_ranks
    [:taxonomy_kingdom, :taxonomy_phylum, :taxonomy_class, :taxonomy_order, :taxonomy_family, :taxonomy_genus, :taxonomy_species, :taxonomy_subspecies]
  end

  def gbif_taxonomy_array
    gbif_ranks.map { |rank| self.send(rank)&.first }.compact
  end

  # ToDoValk: Replace with persister method when BiologicalSpecimen gets Valkyrized
  def objects
    BiologicalSpecimen.where(taxonomy_id: id.to_s).to_a
  end

  def media
    objects.map(&:media).flatten
  end
end
