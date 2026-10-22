# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Morphosource::Dashboard::Collections::OrganizationCollectionsController', type: :request do
  # Not a factory user: the factories stub #groups, which would hide the managers role.
  let(:manager)      { User.create(email: 'manager@example.com', password: 'password') }
  let(:admin)        { FactoryBot.create(:admin) }
  let(:reviewer)     { FactoryBot.create(:contributor) }
  let(:reviewer2)    { FactoryBot.create(:contributor) }
  let(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: manager.ms_id) }

  before do
    Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    organization.managers << manager
    organization.managers_group.save
  end

  def patch_organization(organization_params)
    patch "/dashboard/organizations/#{organization.id}", params: { organization_collection: organization_params }
    organization.reload
  end

  describe 'PATCH update' do
    context 'as a manager' do
      before { sign_in manager }

      it 'keeps the custom reviewer list through a round trip to manager mode' do
        patch_organization(managers_are_download_reviewers: 'false',
                           custom_download_reviewer_users: ["#{reviewer.ms_id},#{reviewer2.ms_id}"])
        expect(organization.managers_are_download_reviewers).to be(false)
        expect(organization.custom_download_reviewer_users).to eq([reviewer.ms_id, reviewer2.ms_id])

        patch_organization(managers_are_download_reviewers: 'true',
                           custom_download_reviewer_users: ["#{reviewer.ms_id},#{reviewer2.ms_id}"])
        expect(organization.managers_are_download_reviewers).to be(true)
        expect(organization.custom_download_reviewer_users).to eq([reviewer.ms_id, reviewer2.ms_id])

        patch_organization(managers_are_download_reviewers: 'false')
        expect(organization.managers_are_download_reviewers).to be(false)
        expect(organization.custom_download_reviewer_users).to eq([reviewer.ms_id, reviewer2.ms_id])
      end

      it 'publishes no reviewer event when the stored custom list is posted back unchanged' do
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id, reviewer2.ms_id]
        organization.save!
        allow(Hyrax.publisher).to receive(:publish).and_call_original

        patch_organization(managers_are_download_reviewers: 'false',
                           custom_download_reviewer_users: ["#{reviewer.ms_id},#{reviewer2.ms_id}"])

        expect(Hyrax.publisher).not_to have_received(:publish).with('organization.reviewers.updated', anything)
      end

      it 'drops the administrator-controlled eligibility flag' do
        patch_organization(managers_are_download_reviewers: 'false', reviews_object_media_downloads: 'true')

        expect(organization.managers_are_download_reviewers).to be(false)
        expect(organization.reviews_object_media_downloads).to be_nil
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'sets the eligibility flag' do
        patch_organization(reviews_object_media_downloads: 'true')

        expect(organization.reviews_object_media_downloads).to be(true)
      end
    end
  end

  describe 'GET permissions' do
    let(:eligibility_select) { 'select[name="organization_collection[reviews_object_media_downloads]"]' }

    it 'shows an admin the editable eligibility flag' do
      sign_in admin
      get "/dashboard/organizations/#{organization.id}/permissions"
      page = Nokogiri::HTML(response.body)

      expect(page.at_css(eligibility_select)).to be_present
      expect(page.css('input[name="organization_collection[managers_are_download_reviewers]"]').size).to eq(2)
    end

    it 'shows a manager the eligibility flag read-only' do
      sign_in manager
      get "/dashboard/organizations/#{organization.id}/permissions"
      page = Nokogiri::HTML(response.body)

      expect(page.at_css(eligibility_select)).to be_nil
      expect(page.text).to include(I18n.t('hyrax.organization.permissions.reviews_object_media_downloads.text'))
      expect(page.css('input[name="organization_collection[managers_are_download_reviewers]"]').size).to eq(2)
    end
  end

  describe 'GET about' do
    let(:reviewer_label) { I18n.t('morphosource.collections.view.about.permissions.download_reviewer') }

    it 'shows the download reviewers of an eligible organization' do
      organization.update!(reviews_object_media_downloads: true)
      get "/organizations/#{organization.id}/about"

      label = Nokogiri::HTML(response.body).css('.showcase-label').find { |node| node.text.strip == reviewer_label }

      expect(label).to be_present
      expect(label.next_element.text).to include(manager.name_or_email)
    end

    it 'hides the download reviewers of an ineligible organization' do
      get "/organizations/#{organization.id}/about"

      expect(response.body).not_to include(reviewer_label)
    end
  end
end
