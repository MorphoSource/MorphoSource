# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::PermissionsHelper, type: :helper do

  describe 'PUBLICATIONS_OPTIONS' do
    it {  expect(subject::PUBLICATION_OPTIONS).to match_array(
      [
        ["Publish with Open Download", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC],
        ["Publish with Restricted Download", "restricted_download"],
        ["Private", Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE]
      ]
    ) }
  end

  describe 'MULTI_VALUE' do
    it { expect(subject::MULTI_VALUE).to match_array(['license', 'agreement_uri', 'funding', 'publisher']) }
  end

  describe 'SINGLE_VALUE' do
    it { expect(subject::SINGLE_VALUE).to match_array(['rights_statement', 'permits_commercial_use', 'permits_3d_use', 'cite_as']) }
  end

  describe 'alert' do
    let(:organization)  { Organization.new(title: ['Organization Title']) }

    it 'inserts the organization name into the alert' do
      expect(helper.alert(organization)).to eq('This value has been suggested by Organization Title')
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

  describe 'form_model_name, download_permission_input' do
    context 'media' do
      let(:media) { Media.create(title: ['title']) }
      let(:form)  { Hyrax::MediaForm.new(media, nil, nil) }
      it 'has the correct values' do
        helper.simple_form_for form, url: '' do |f|
          expect(helper.form_model_name(f)).to eq('media')
          expect(helper.download_permission_input(f)).to eq("<input type='hidden' id= 'media_download_permission' name='media[visibility]' class='download-permission' value= #{download_permission(f)} >".html_safe)
        end
      end
    end
    context 'organization' do
      let(:organization)  { Organization.new() }
      let(:form)          { Hyrax::OrganizationForm.new(organization, nil, nil) }
      it 'has the correct values' do
        helper.simple_form_for form, url: '' do |f|
          expect(helper.form_model_name(f)).to eq('organization')
          expect(helper.download_permission_input(f)).to eq("<input type='hidden' id= 'organization_download_permission' name='organization[download_permission]' class='download-permission' value= #{download_permission(f)} >".html_safe)
        end
      end
    end
    context 'organization collection' do
      let(:organization)  { FactoryBot.build(:organization_collection) }
      let(:form)          { Morphosource::Forms::Collections::OrganizationCollectionForm.new(organization, nil, nil) }
      it 'has the correct values' do
        helper.simple_form_for form, url: '' do |f|
          expect(helper.form_model_name(f)).to eq('organization_collection')
          expect(helper.download_permission_input(f)).to eq("<input type='hidden' id= 'organization_collection_download_permission' name='organization_collection[download_permission]' class='download-permission' value= #{download_permission(f)} >".html_safe)
        end
      end
    end
  end

  describe 'download_permission, badge_class, human_readable_publication_status' do
    context 'media' do
      let(:media) { Media.create(title: ['title']) }
      let(:form)  { Hyrax::MediaForm.new(media, nil, nil) }
      context 'media is open' do
        before do
          media.visibility = 'open'
          media.fileset_accessibility = ['open']
          media.save
        end
        it 'is open' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('open')
            expect(helper.badge_class(f)).to eq('badge badge-success')
            expect(helper.human_readable_publication_status(f)).to eq('Open Download')
          end
        end
      end
      context 'media is restricted download' do
        before do
          media.visibility = 'open'
          media.fileset_accessibility = ['restricted_download']
          media.save
        end
        it 'is restricted_download' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('restricted_download')
            expect(helper.badge_class(f)).to eq('badge badge-info')
            expect(helper.human_readable_publication_status(f)).to eq('Restricted Download')
          end
        end
      end
      context 'media is private' do
        before do
          media.visibility = 'restricted'
          media.fileset_accessibility = ['private']
          media.save
        end
        it 'is private' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('private')
            expect(helper.badge_class(f)).to eq('badge badge-danger')
            expect(helper.human_readable_publication_status(f)).to eq('Private')
          end
        end
      end
    end
    context 'organization' do
      let(:organization) { Organization.create(title: ['title']) }
      let(:form)  { Hyrax::OrganizationForm.new(organization, nil, nil) }
      context 'organization download permission is open' do
        before do
          organization.download_permission = ['open']
          organization.save
        end
        it 'is open' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('open')
            expect(helper.badge_class(f)).to eq('badge badge-success')
            expect(helper.human_readable_publication_status(f)).to eq('Open Download')
          end
        end
      end
      context 'organization download permission is restricted download' do
        before do
          organization.download_permission = ['restricted_download']
          organization.save
        end
        it 'is restricted_download' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('restricted_download')
            expect(helper.badge_class(f)).to eq('badge badge-info')
            expect(helper.human_readable_publication_status(f)).to eq('Restricted Download')
          end
        end
      end
      context 'organization download permission is private' do
        before do
          organization.download_permission = ['private']
          organization.save
        end
        it 'is private' do
          helper.simple_form_for form, url: '' do |f|
            expect(helper.download_permission(f)).to eq('private')
            expect(helper.badge_class(f)).to eq('badge badge-danger')
            expect(helper.human_readable_publication_status(f)).to eq('Private')
          end
        end
      end
    end
  end
end
