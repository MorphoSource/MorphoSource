require 'rails_helper'

RSpec.describe 'hyrax/media/_edit_media_download_reviewers', type: :view do
  let(:user)          { FactoryBot.create(:contributor) }
  let(:reviewer)      { FactoryBot.create(:contributor) }
  let(:other_reviewer) { FactoryBot.create(:contributor) }
  let(:accessibility) { 'restricted_download' }
  let(:attributes)    { {} }
  let(:media) do
    FactoryBot.create(:media, owner: user.ms_id, depositor: user.ms_id, fileset_accessibility: [accessibility], **attributes)
  end
  let(:object_organizations) { [] }
  let(:organization) do
    FactoryBot.create(:organization_collection, title: ['Eligible Org'], depositor: user.ms_id,
                                                reviews_object_media_downloads: true)
  end
  let(:ineligible_organization) do
    FactoryBot.create(:organization_collection, title: ['Ineligible Org'], depositor: user.ms_id)
  end
  let(:other_ineligible_organization) do
    FactoryBot.create(:organization_collection, title: ['Other Ineligible Org'], depositor: user.ms_id)
  end
  let(:document) { Nokogiri::HTML.fragment(rendered_block) }

  let(:block)         { document.at_css('#media-download-reviewers') }
  let(:org_radio)     { document.at_css('#media_download_reviewer_mode_object_organization') }
  let(:own_radio)     { document.at_css('#media_download_reviewer_mode_record_users') }
  let(:picker)        { document.at_css('#media_record_download_reviewer_users') }
  let(:picker_row)    { document.at_css('#media-record-download-reviewers') }
  let(:via)           { document.at_css('#media-download-reviewers-via').text.strip }

  def rendered_block
    allow(media).to receive(:organizations).and_return(object_organizations)
    allow(view).to receive(:current_user).and_return(user)
    form = Hyrax::MediaForm.new(media, nil, nil)

    view.simple_form_for(form, as: 'media', url: '/') do |f|
      view.render('hyrax/media/edit_media_download_reviewers', f: f)
    end
  end

  it 'groups the radio pair under a legend' do
    expect(document.at_css('#media-download-reviewers fieldset legend').text)
      .to eq(I18n.t('morphosource.reviewers.media.legend'))
  end

  it 'keeps the radios and picker inside the block the DOI lock exempts' do
    [org_radio, own_radio, picker].each do |input|
      expect(input.ancestors('#media-download-reviewers')).to be_present
    end
  end

  it 'uses no id the download permission script would overwrite' do
    expect(document.css('[id*="_download_permission"]')).to be_empty
  end

  context 'in record_users mode with a populated list' do
    let(:attributes) { { record_download_reviewer_users: [reviewer.ms_id, other_reviewer.ms_id] } }

    it 'checks the own radio, shows the picker and posts the list comma-joined' do
      expect(own_radio['checked']).to be_present
      expect(org_radio['checked']).to be_nil
      expect(picker_row['class']).not_to include('d-none')
      expect(picker['value'].split(',')).to match_array([reviewer.ms_id, other_reviewer.ms_id])
      expect(picker['name']).to eq('media[record_download_reviewer_users][]')
    end

    it 'reads out the reviewers and the record-list source' do
      expect(block.text).to include(reviewer.name_or_email)
      expect(via).to eq(I18n.t('morphosource.reviewers.media.via.record_users'))
    end
  end

  context 'in object_organization mode' do
    let(:object_organizations) { [organization] }
    let(:attributes) do
      { download_reviewer_mode: 'object_organization', record_download_reviewer_users: [reviewer.ms_id] }
    end

    it 'checks the organization radio and hides, but keeps, the picker' do
      expect(org_radio['checked']).to be_present
      expect(picker_row['class']).to include('d-none')
      expect(picker['disabled']).to be_nil
      expect(picker['value']).to eq(reviewer.ms_id)
    end

    it 'names the organization in the radio label' do
      expect(document.at_css('label[for="media_download_reviewer_mode_object_organization"]').text)
        .to include('Eligible Org')
    end

    it 'shows the batch User and the staff line when the organization has no managers' do
      expect(block.text).to include(User.batch_user.name_or_email)
      expect(via).to eq(I18n.t('morphosource.reviewers.media.via.staff'))
      expect(block.text).not_to include('None')
    end
  end

  context 'when Download permission is not Restricted Download' do
    let(:accessibility) { 'open' }

    it 'disables every input and shows the factual notice' do
      expect(org_radio['disabled']).to be_present
      expect(own_radio['disabled']).to be_present
      expect(picker['disabled']).to be_present
      expect(block['class']).to include('text-muted')
      expect(document.at_css('#media-download-reviewers-not-restricted')['class']).not_to include('d-none')
    end
  end

  context 'when Object Organizations are ineligible' do
    let(:object_organizations) { [organization, ineligible_organization, other_ineligible_organization] }

    it 'disables and marks the organization radio and names every blocker' do
      expect(org_radio['disabled']).to be_present
      expect(org_radio['data-org-blocked']).to be_present
      notice = document.at_css('#media-download-reviewers-unavailable').text
      expect(notice).to include('Ineligible Org and Other Ineligible Org')
      expect(notice).to include(I18n.t('morphosource.reviewers.media.every_eligible'))
    end
  end

  context 'with no Object Organizations' do
    it 'disables the organization radio with the zero-organization notice' do
      expect(org_radio['disabled']).to be_present
      expect(document.at_css('#media-download-reviewers-unavailable').text.strip)
        .to eq(I18n.t('morphosource.reviewers.media.unavailable_none'))
    end

    it 'names the media owner in the hint' do
      expect(picker_row.text).to include(user.name_or_email)
      expect(via).to eq(I18n.t('morphosource.reviewers.media.via.owner_user'))
    end
  end

  context 'on a Grandfathered media' do
    let(:object_organizations) { [ineligible_organization] }
    let(:attributes) { { download_reviewer_mode: 'object_organization' } }

    it 'keeps the organization radio checked and enabled with the exit warning' do
      expect(org_radio['checked']).to be_present
      expect(org_radio['disabled']).to be_nil
      expect(org_radio['data-org-blocked']).to be_nil
      expect(document.at_css('#media-download-reviewers-grandfathered').text).to include('Ineligible Org')
    end
  end
end
