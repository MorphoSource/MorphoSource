# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::PermissionsHelper, type: :helper do

  describe 'PUBLICATIONS_OPTIONS' do
    it {  expect(subject::PUBLICATION_OPTIONS).to match_array(
      [
        ["Publish with Open Download", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC],
        ["Publish with Restricted Download", "restricted_download"],
        ["Publish with No Download", "preview_only"],
        ["Publish with Hidden File", "hidden"],
        ["Private", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE]
      ]
    ) }
  end

  describe 'MULTI_VALUE' do
    it { expect(subject::MULTI_VALUE).to match_array(['license', 'agreement_uri', 'funding', 'publisher']) }
  end

  describe 'SINGLE_VALUE' do
    it { expect(subject::SINGLE_VALUE).to match_array(['rights_statement', 'terms_of_use', 'permits_commercial_use', 'permits_3d_use', 'cite_as']) }
  end

  describe 'alert' do
    let(:organization)  { Organization.new(title: ['Organization Title']) }

    it 'inserts the organization name into the alert' do
      expect(helper.alert(organization)).to eq('This value has been suggested by Organization Title')
    end
  end

  describe 'reviewer_email' do
    let!(:reviewer)  { User.create(email: 'email@email.com', password: 'password') }
    let(:media)     { Media.new() }
    let(:form)      { Hyrax::MediaForm.new(media, nil, nil) }

    context 'A default reviewer exists' do
      before do
        media.download_reviewer = [reviewer.ms_id]
      end
      it 'returns the reviewer email' do
        helper.simple_form_for form, url: '' do |f|
          expect(helper.reviewer_email(f)).to eq(reviewer.email)
        end
      end
    end
    context 'A default reviewer does not exist' do
      before do
        media.download_reviewer = []
      end
      it 'returns the reviewer email' do
        helper.simple_form_for form, url: '' do |f|
          expect(helper.reviewer_email(f)).to eq('')
        end
      end
    end
  end

  describe 'default_present?' do
    let(:media) { Media.new() }
    let(:form)  { Hyrax::MediaForm.new(media, nil, nil) }

    context 'default permission field has a value' do
      before do
        media.license = ['license']
      end
      it 'returns true' do
        expect(helper.default_present?(form, 'license')).to be(true)
      end
    end
    context 'default permission field does not have a value' do
      before do
        media.license = []
      end
      it 'returns true' do
        expect(helper.default_present?(form, 'license')).to be(false)
      end
    end
  end
end
