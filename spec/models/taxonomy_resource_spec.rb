# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource TaxonomyResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe TaxonomyResource do
  subject(:work) { described_class.new }

  it_behaves_like 'a Hyrax::Work'

  context 'includes schema defined metadata' do
    it { is_expected.to respond_to(:taxonomy_domain) }
    it { is_expected.to respond_to(:taxonomy_kingdom) }
    it { is_expected.to respond_to(:taxonomy_phylum) }
    it { is_expected.to respond_to(:taxonomy_superclass) }
    it { is_expected.to respond_to(:taxonomy_class) }
    it { is_expected.to respond_to(:taxonomy_subclass) }
    it { is_expected.to respond_to(:taxonomy_superorder) }
    it { is_expected.to respond_to(:taxonomy_order) }
    it { is_expected.to respond_to(:taxonomy_suborder) }
    it { is_expected.to respond_to(:taxonomy_superfamily) }
    it { is_expected.to respond_to(:taxonomy_family) }
    it { is_expected.to respond_to(:taxonomy_subfamily) }
    it { is_expected.to respond_to(:taxonomy_tribe) }
    it { is_expected.to respond_to(:taxonomy_genus) }
    it { is_expected.to respond_to(:taxonomy_subgenus) }
    it { is_expected.to respond_to(:taxonomy_species) }
    it { is_expected.to respond_to(:taxonomy_subspecies) }
    it { is_expected.to respond_to(:trusted) }
    it { is_expected.to respond_to(:gbif_key) }
  end
end
