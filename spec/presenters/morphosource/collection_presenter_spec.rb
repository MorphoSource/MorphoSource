require 'rails_helper'

RSpec.describe Morphosource::CollectionPresenter do
  let(:collection)      { FactoryBot.build(:team, id: '123') }
  let(:collection_doc)  { SolrDocument.new(collection.to_solr) }

  subject { described_class.new(collection_doc, double)}

  before do
    allow(Collection).to receive(:find).with(collection.id).and_return(collection)
    allow(collection).to receive(:managers).and_return([])
  end

  describe 'model' do
    it { expect(subject.model).to be_a(Hyrax::SolrDocumentBehavior::ModelWrapper) }
  end

  # The configured default manager is seeded onto every organization and reaches
  # this collection through Collection#copy_parent_membership
  describe 'default manager filtering' do
    let(:default_manager) { FactoryBot.create(:contributor) }
    let(:manager)         { FactoryBot.create(:contributor) }

    # Matches Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer#user_link
    def user_link(user)
      %(<a href="/users/#{user.ms_id}">#{user.name_or_email}</a>)
    end

    def every_manager_link
      [user_link(default_manager), user_link(manager)].join(', ')
    end

    before do
      allow(collection).to receive(:managers).and_return([default_manager, manager])
    end

    context 'when a default organization manager is configured' do
      before do
        allow(Morphosource).to receive(:default_organization_manager).and_return(default_manager.ms_id)
      end

      it 'drops it from #managers_for_display' do
        expect(subject.managers_for_display).to eq([manager])
      end

      it 'omits it from #manager_links_for_display' do
        expect(subject.manager_links_for_display).to eq(user_link(manager))
      end

      it 'keeps it in #managers' do
        expect(subject.managers).to eq([default_manager, manager])
      end

      it 'does not query for the configured manager separately' do
        expect(User).not_to receive(:find_by)
        subject.manager_links_for_display
      end

      it 'still renders a list handed to #manager_links directly' do
        expect(subject.manager_links([default_manager])).to eq(user_link(default_manager))
      end
    end

    context 'when no default organization manager is configured' do
      before do
        allow(Morphosource).to receive(:default_organization_manager).and_return(nil)
      end

      it 'renders every manager' do
        expect(subject.manager_links_for_display).to eq(every_manager_link)
      end
    end

    context 'when the configured default manager matches no user' do
      before do
        allow(Morphosource).to receive(:default_organization_manager).and_return('no_such_ms_id')
      end

      it 'renders every manager' do
        expect(subject.manager_links_for_display).to eq(every_manager_link)
      end
    end
  end
end
