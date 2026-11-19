require 'rails_helper'

RSpec.describe 'morphosource/dashboard/collections/permissions/_organization_download_reviewers', type: :view do
  let(:user)         { FactoryBot.create(:contributor) }
  let(:reviewer)     { FactoryBot.create(:contributor) }
  let(:manager)      { FactoryBot.create(:contributor) }
  let(:attributes)   { { reviews_object_media_downloads: true } }
  let(:organization) { FactoryBot.create(:organization_collection, depositor: user.ms_id, **attributes) }
  let(:managers)     { [manager] }
  let(:document)     { Nokogiri::HTML.fragment(rendered_block) }

  let(:managers_radio) { document.at_css('#organization_collection_managers_are_download_reviewers_true') }
  let(:custom_radio)   { document.at_css('#organization_collection_managers_are_download_reviewers_false') }
  let(:picker)         { document.at_css('#organization_collection_custom_download_reviewer_users') }
  let(:picker_row)     { document.at_css('#organization-custom-download-reviewers') }

  def rendered_block
    presenter = Morphosource::Collections::OrganizationPresenter.new(SolrDocument.find(organization.id), nil)
    allow(presenter).to receive(:managers).and_return(managers)
    view.assign(collection: organization, presenter: presenter)
    allow(view).to receive(:current_user).and_return(user)
    form = Morphosource::Forms::Collections::OrganizationCollectionForm.new(organization, nil, nil)

    view.simple_form_for(form, url: '/') do |f|
      view.render('morphosource/dashboard/collections/permissions/organization_download_reviewers', f: f)
    end
  end

  context 'in manager mode' do
    it 'checks the managers radio and hides the picker' do
      expect(managers_radio['checked']).to be_present
      expect(custom_radio['checked']).to be_nil
      expect(picker_row['class']).to include('d-none')
      expect(picker['disabled']).to be_nil
    end
  end

  context 'in custom mode' do
    let(:attributes) do
      { reviews_object_media_downloads: true, managers_are_download_reviewers: false,
        custom_download_reviewer_users: [reviewer.ms_id] }
    end

    it 'checks the custom radio and shows the picker with its reviewers' do
      expect(custom_radio['checked']).to be_present
      expect(picker_row['class']).not_to include('d-none')
      expect(picker['name']).to eq('organization_collection[custom_download_reviewer_users][]')
      expect(picker['value']).to eq(reviewer.ms_id)
      expect(JSON.parse(picker['data-reviewers']).first['user_key']).to eq(reviewer.ms_id)
      expect(document.text).to include(reviewer.name_or_email)
    end
  end

  context 'when the mode was never written' do
    before do
      organization.managers_are_download_reviewers = nil
      organization.managers_are_download_reviewers_will_change!
      organization.save!
    end

    it 'checks neither radio and says so' do
      expect(managers_radio['checked']).to be_nil
      expect(custom_radio['checked']).to be_nil
      expect(document.text).to include(I18n.t('morphosource.reviewers.organization.unset'))
    end
  end

  context 'without Reviewer Eligibility' do
    let(:attributes) { {} }

    it 'disables every control and explains why' do
      expect(managers_radio['disabled']).to be_present
      expect(custom_radio['disabled']).to be_present
      expect(picker['disabled']).to be_present
      expect(document.text).to include('Download review has not been enabled for this organization')
    end

    context 'and no managers' do
      let(:managers) { [] }

      it 'does not ask for a manager' do
        expect(managers_radio['disabled']).to be_present
        expect(document.text).not_to include('This organization has no managers.')
      end
    end
  end

  context 'with no managers' do
    let(:managers) { [] }

    it 'disables the managers radio and asks for a manager' do
      expect(managers_radio['disabled']).to be_present
      expect(custom_radio['disabled']).to be_nil
      expect(document.text).to include('This organization has no managers.')
    end

    it 'names the staff fallback in the readout' do
      expect(document.text).to include(I18n.t('morphosource.reviewers.organization.current_empty'))
    end
  end

  context 'with a Manager' do
    let(:current_label) { I18n.t('morphosource.reviewers.organization.current_label') }

    before do
      organization.managers << manager
      organization.managers_group.save!
      organization.update_index
    end

    it 'names the resolved Manager in the readout' do
      label = document.css('.showcase-label').find { |node| node.text.strip == current_label }

      expect(label.next_element.text).to include(manager.name_or_email)
    end
  end

  context 'with Require enforcement' do
    let(:attributes) { { reviews_object_media_downloads: true, permissions_enforcement_mode: ['Require'] } }

    it 'states what Require does' do
      expect(document.text).to include(I18n.t('morphosource.reviewers.organization.require'))
    end
  end
end
