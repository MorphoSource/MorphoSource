# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Hyrax::Actors::TaxonomyActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }
  let(:work) { Taxonomy.new }
  let(:ability) { Ability.new(User.new(id: 5)) }
  let(:rank_attrs) { { "taxonomy_domain" => ["Domain"],
                  "taxonomy_kingdom" => ["Kingdom"],
                  "taxonomy_phylum" => ["Phylum"],
                  "taxonomy_superclass" => [],
                  "taxonomy_class" => ["Class"],
                  "taxonomy_subclass" => [],
                  "taxonomy_superorder" => [],
                  "taxonomy_order" => ["Order"],
                  "taxonomy_suborder" => [],
                  "taxonomy_superfamily" => [],
                  "taxonomy_family" => ["Family"],
                  "taxonomy_subfamily" => [],
                  "taxonomy_tribe" => [],
                  "taxonomy_genus" => ["Genus"],
                  "taxonomy_subgenus" => ["Subgenus"],
                  "taxonomy_species" => ["Species"],
                  "taxonomy_subspecies" => [] } }

  let(:new_attrs) { rank_attrs.merge({ "source" => ["iDigBio"], "trusted" => ["Yes"] }) }

  let(:blank_attrs) {rank_attrs.merge({ "source" => [], "trusted" => [] }) }

  describe '#create' do

    context 'user provides the taxonomy' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, rank_attrs) }

      it 'changes the title attribute' do
        expect { subject.create(env) }.to change{env.attributes['title']}.to([ "Domain > Kingdom > Phylum > Class > Order > Family > Genus > Subgenus > Species" ])
      end

      it "changes the source to 'user-provided'" do
        expect { subject.create(env) }.to change{env.attributes['source']}.to (["User-Provided"])
      end
      it "changes trusted to 'No'" do
        expect { subject.create(env) }.to change{env.attributes['trusted']}.to (["No"])
      end
    end

    context 'user imports the taxonomy' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, new_attrs) }

      it "does not change the source to 'User-Provided'" do
        expect { subject.create(env) }.to_not change{env.attributes['source']}
      end
      it "Does not change trusted to 'No'" do
        expect { subject.create(env) }.to_not change{env.attributes['trusted']}
      end
    end
  end

  describe '#update' do
    before do
      env.curation_concern.title = ["Previous title"]
      env.curation_concern.source = ["Previous source"]
      env.curation_concern.trusted = ["Previous trusted"]
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    context 'An admin updates ranks, source and trusted' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, new_attrs) }

      it 'changes the title attribute' do
        expect { subject.update(env) }.to change{env.attributes['title']}.to([ "Domain > Kingdom > Phylum > Class > Order > Family > Genus > Subgenus > Species" ])
      end

      it 'changes the source and trusted values' do
        subject.update(env)
        expect(work.source).to eq(["iDigBio"])
        expect(work.trusted).to eq(["Yes"])
      end

    end

    context 'user does not enter a new source or trusted' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, rank_attrs) }

      it 'does not update previous source and trusted values' do
        subject.update(env)
        expect(work.source).to eq(["Previous source"])
        expect(work.trusted).to eq(["Previous trusted"])
      end
    end

    context 'source and trusted attributes are blank' do
      let(:env) { Hyrax::Actors::Environment.new(work, ability, blank_attrs) }

      it 'does not update the previous source and trusted values' do
        subject.update(env)
        expect(work.source).to eq(["Previous source"])
        expect(work.trusted).to eq(["Previous trusted"])
      end
    end
  end
end
