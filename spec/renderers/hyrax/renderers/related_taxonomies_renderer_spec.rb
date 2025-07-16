require 'rails_helper'

RSpec.describe Hyrax::Renderers::RelatedTaxonomiesRenderer do

  let(:field)             { :biological_specimens }
  let(:taxonomy)          { Taxonomy.new(id: "def456", title: ["Domain > Kingdom > Phylum"], depositor: "msid333")}
  let(:canonical_taxonomy){ Taxonomy.new(id: "ghi789", title: ["Superclass > Class > Subclass"], depositor: "msid333") }
  let(:trusted_taxonomy)  { Taxonomy.new(id: "jkl123", title: ["Superorder > Order > Suborder"], depositor: "msid333")}
  let(:user_taxonomy)     { Taxonomy.new(id: "mno456", title: ["Superfamily > Family > Subfamily"], depositor: "msid333") }
  let(:user)              { User.new(email: "example@email.com", display_name: "D. Duck", ms_id: "msid333")}
  let(:child_specimen)    { BiologicalSpecimen.create(id: "abc123", title: ["test biological specimen"] ) }
  let(:renderer)          { described_class.new(field, [child_specimen], locale: :en, id: taxonomy.id) }
  let(:taxonomy_methods)  {[:canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies]}
  let(:subject)           { Nokogiri::HTML(renderer.render) }

  it 'delegates taxonomy methods to @specimen' do
    taxonomy_methods.each do |method|
      expect(@specimen).to receive(method)
      renderer.send(method)
    end
  end
end
