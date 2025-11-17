# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Hyrax::TaxonomyPresenter do

  let(:work) { valkyrie_create(:taxonomy_resource, title: ["taxonomy title"]) }
  let(:taxonomy_terms) {[:taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies, :trusted, :gbif_key]}

  subject { described_class.new(SolrDocument.find(work.id.to_s), nil) }

  it 'delegates all the terms to solr' do
    taxonomy_terms.each do |method|
      expect(subject).to delegate_method(method).to(:solr_document)
    end
  end

  describe "#biological_specimens" do
    let(:bso1) { BiologicalSpecimen.create(title: ["bso1 title"], vouchered: ["Yes"], taxonomy_id: [work.id]) }
    let(:bso2) { BiologicalSpecimen.create(title: ["bso2 title"], vouchered: ["No"], taxonomy_id: [work.id]) }

    it "returns all children (which can only be biological specimens)" do
      expect(subject.biological_specimens).to match_array([bso1, bso2])
    end
  end

end
