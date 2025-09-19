# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource TaxonomyResource`
class TaxonomyResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:taxonomy_resource)
end
