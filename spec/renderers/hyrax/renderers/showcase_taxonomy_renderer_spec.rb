require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::Renderers::ShowcaseTaxonomyRenderer do

  let(:full_attrs) {{
    id: 'abc123',
    title: ["domain > kingdom > genus > species"],
    taxonomy_domain: ["domain"],
    taxonomy_kingdom: ["kingdom"],
    taxonomy_phylum: ["phylum"],
    taxonomy_superclass: ["superclass"],
    taxonomy_class: ["class"],
    taxonomy_subclass: ["subclass"],
    taxonomy_superorder: ["superorder"],
    taxonomy_order: ["order"],
    taxonomy_suborder: ["suborder"],
    taxonomy_superfamily: ["superfamily"],
    taxonomy_family: ["family"],
    taxonomy_subfamily: ["subfamily"],
    taxonomy_tribe: ["tribe"],
    taxonomy_genus: ["genus"],
    taxonomy_subgenus: ["subgenus"],
    taxonomy_species: ["species"],
    taxonomy_subspecies: ["subspecies"] }}

  let(:some_attrs) {{
    id: 'def456',
    title: ["domain2 > kingdom2 > genus2 > species2"],
    taxonomy_domain: [],
    taxonomy_kingdom: ["kingdom"],
    taxonomy_phylum: ["phylum"],
    taxonomy_superclass: [],
    taxonomy_class: ["class"],
    taxonomy_subclass: [],
    taxonomy_superorder: [],
    taxonomy_order: ["order"],
    taxonomy_suborder: [],
    taxonomy_superfamily: [],
    taxonomy_family: ["family"],
    taxonomy_subfamily: [],
    taxonomy_tribe: [],
    taxonomy_genus: ["genus"],
    taxonomy_subgenus: [],
    taxonomy_species: ["species"],
    taxonomy_subspecies: [] }}

  describe "#render" do
    subject                 { Nokogiri::HTML(renderer.render) }
    let(:expected)          { Nokogiri::HTML(content) }
    let(:block)             { "collapse-taxonomy-imxatwyl" }

    before do
      allow_any_instance_of(described_class).to receive(:create_block).and_return(block)
    end

    context 'all ranks are filled out' do
      let(:field)                      { :canonical_taxonomy_object }
      let(:canonical_taxonomy_object)  { Taxonomy.new(full_attrs) }
      let(:label)                      { I18n.t('morphosource.taxonomy.labels.canonical')}
      let(:renderer)                   { described_class.new(field, [canonical_taxonomy_object], data_parent: "taxonomy-accordion-group", label: label, is_collapsed: true) }

      let(:content) do
        %( <div class="panel">
       <div class="row">
       <div class="col-xs-6 showcase-label taxonomy-label">Organizational</div>
       <div class="col-xs-5 showcase-value taxonomy-title">genus subgenus species subspecies</div>
       <span data-toggle="collapse" data-parent="#taxonomy-accordion-group" href="#collapse-taxonomy-imxatwyl" class="col-xs-1 glyphicon glyphicon-triangle-bottom collapse-taxonomy-imxatwyl"></span>
       </div>
       <div id="collapse-taxonomy-imxatwyl" class="panel-collapse collapse collapse-accordion">
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Domain</div>
                             <div class="col-xs-6 showcase-value">domain</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Kingdom</div>
                             <div class="col-xs-6 showcase-value">kingdom</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Phylum</div>
                             <div class="col-xs-6 showcase-value">phylum</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Superclass</div>
                             <div class="col-xs-6 showcase-value">superclass</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Class</div>
                             <div class="col-xs-6 showcase-value">class</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Subclass</div>
                             <div class="col-xs-6 showcase-value">subclass</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Superorder</div>
                             <div class="col-xs-6 showcase-value">superorder</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Order</div>
                             <div class="col-xs-6 showcase-value">order</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Suborder</div>
                             <div class="col-xs-6 showcase-value">suborder</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Superfamily</div>
                             <div class="col-xs-6 showcase-value">superfamily</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Family</div>
                             <div class="col-xs-6 showcase-value">family</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Subfamily</div>
                             <div class="col-xs-6 showcase-value">subfamily</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Tribe</div>
                             <div class="col-xs-6 showcase-value">tribe</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Genus</div>
                             <div class="col-xs-6 showcase-value">genus</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Subgenus</div>
                             <div class="col-xs-6 showcase-value">subgenus</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Species</div>
                             <div class="col-xs-6 showcase-value">species</div>
                           </div>
       <div class="row taxonomy-rank">
                             <div class="col-xs-6 showcase-label">Subspecies</div>
                             <div class="col-xs-6 showcase-value">subspecies</div>
                           </div>
       </div>
       </div> )
      end

      it 'displays all the rank labels and values' do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context 'some ranks are left blank' do

      let(:field)               { :trusted_taxonomies }
      let(:taxonomy1)           { Taxonomy.new(some_attrs) }
      let(:trusted_taxonomies)  { [ taxonomy1 ] }
      let(:label)               { I18n.t('morphosource.taxonomy.labels.trusted') }
      let(:renderer)            { described_class.new(field, trusted_taxonomies, data_parent: "taxonomy-accordion-group", label: label, is_collapsed: true) }

      let(:content) do
      %(  <div class='panel'>
            <div class="row">
              <div class="col-xs-6 showcase-label taxonomy-label">#{label}</div>
              <div class="col-xs-5 showcase-value taxonomy-title">
                genus species
              </div>
              <span data-toggle="collapse" data-parent="#taxonomy-accordion-group" href="#collapse-taxonomy-imxatwyl" class="col-xs-1 glyphicon glyphicon-triangle-bottom collapse-taxonomy-imxatwyl"></span>
            </div>
            <div id=collapse-taxonomy-imxatwyl class='panel-collapse collapse collapse-accordion'>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Domain</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Kingdom</div>
              <div class="col-xs-6 showcase-value">kingdom</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Phylum</div>
              <div class="col-xs-6 showcase-value">phylum</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Superclass</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Class</div>
              <div class="col-xs-6 showcase-value">class</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Subclass</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Superorder</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Order</div>
              <div class="col-xs-6 showcase-value">order</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Suborder</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Superfamily</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Family</div>
              <div class="col-xs-6 showcase-value">family</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Subfamily</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Tribe</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Genus</div>
              <div class="col-xs-6 showcase-value">genus</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Subgenus</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Species</div>
              <div class="col-xs-6 showcase-value">species</div>
            </div>
            <div class="row taxonomy-rank">
              <div class="col-xs-6 showcase-label">Subspecies</div>
              <div class="col-xs-6 showcase-value">--</div>
            </div>
          </div>
        </div>)
      end

      it 'displays (Not entered) for blank ranks' do
        expect(subject).to be_equivalent_to(expected)
      end
    end

    context 'canonical_taxonomy' do
      let(:field)                      { :canonical_taxonomy_object }
      let(:canonical_taxonomy_object)  { Taxonomy.new(full_attrs) }
      let(:label)                      { I18n.t('morphosource.taxonomy.labels.canonical')}
      let(:renderer)                   { described_class.new(field, [canonical_taxonomy_object], data_parent: "taxonomy-accordion-group", label: label, is_collapsed: true) }

      it 'displays the label for trusted taxonomies' do
        expect(renderer.render).to include I18n.t('morphosource.taxonomy.labels.canonical')
      end
    end

    context 'trusted_taxonomies' do
      let(:field)               { :trusted_taxonomies }
      let(:taxonomy1)           { Taxonomy.new(some_attrs) }
      let(:trusted_taxonomies)  { [ taxonomy1 ] }
      let(:label)               { I18n.t('morphosource.taxonomy.labels.trusted') }
      let(:renderer)            { described_class.new(field, trusted_taxonomies, data_parent: "taxonomy-accordion-group", label: label, is_collapsed: true) }

      it 'displays the label for trusted taxonomies' do
        expect(renderer.render).to include I18n.t('morphosource.taxonomy.labels.trusted')
      end
    end

    context 'user_taxonomies' do
      let(:field)               { :user_taxonomies }
      let(:taxonomy1)           { Taxonomy.new(full_attrs.merge({ depositor: "msid123"})) }
      let(:taxonomy2)           { Taxonomy.new(some_attrs.merge({ depositor: "msid456"})) }
      let(:user_taxonomies)     { [ taxonomy1, taxonomy2 ] }
      let(:user1)               { User.new(id: 1, email: "example@email.com", display_name: "T. Ruxpin", ms_id: "msid123") }
      let(:user2)               { User.new(id: 2, email: "test@email.com", display_name: nil, ms_id: "msid456") }
      let(:renderer)            { described_class.new(field, user_taxonomies, data_parent: "taxonomy-accordion-group", label: I18n.t('morphosource.taxonomy.labels.user'), is_collapsed: true) }
      let(:markup)              { '' << renderer.render }

      before do
        allow(User).to receive(:find_by_user_key).with("msid123").and_return(user1)
        allow(User).to receive(:find_by_user_key).with("msid456").and_return(user2)
      end

      it 'uses the user-supplied label' do
        expect(markup).to include I18n.t('morphosource.taxonomy.labels.user')
      end

      it 'displays the display name of the taxonomy depositor' do
        expect(markup).to include 'T. Ruxpin'
      end

      it 'does not display the email of the taxonomy depositor if a display name is available' do
        expect(markup).not_to include 'example@email.com: '
      end

      it 'displays the email of the depositor if the display name is nil' do
        expect(markup).to include 'test@email.com'
      end
    end
  end
end
