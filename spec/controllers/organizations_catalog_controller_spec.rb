require 'rails_helper'

RSpec.describe OrganizationsCatalogController, :type => :controller do

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'search_builder_class' do
      it 'is the hyrax catalog search builder' do
        expect(config.search_builder_class).to eq(Morphosource::Catalog::OrganizationsCatalogSearchBuilder)
      end
    end
    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 2 facet fields' do
        expect(facet_fields.count).to eq(2)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end

      describe 'organization type' do
        subject { facet_fields['organization_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Type")
          expect(subject.limit).to eq(5)
        end
      end
    end
  end
end
