# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::CartItems::RequestMessages do
  subject { Class.new { include Morphosource::CartItems::RequestMessages }.new }

  let(:user)      { FactoryBot.create(:registered_user) }
  let(:user2)     { FactoryBot.create(:registered_user) }
  let(:org)       { FactoryBot.create(:organization_collection) }
  let(:reviewers) { [user, user2] }

  describe '#reviewer_display_names' do
    context 'download_reviewer_ssim is present' do
      context 'with user ms_ids' do
        let(:work_doc) { { 'download_reviewer_ssim' => [user.ms_id, user2.ms_id], 'user_with_ownership_ssi' => user.ms_id } }
        it 'returns the corresponding User objects' do
          expect(subject.reviewer_display_names(work_doc, reviewers)).to match_array([user, user2])
        end
      end

      context 'with an org id' do
        let(:work_doc) { { 'download_reviewer_ssim' => [org.id], 'user_with_ownership_ssi' => user.ms_id } }
        it 'returns the corresponding OrganizationCollection' do
          expect(subject.reviewer_display_names(work_doc, reviewers)).to match_array([org])
        end
      end

      context 'with a mix of user ms_ids and org ids' do
        let(:work_doc) { { 'download_reviewer_ssim' => [user.ms_id, org.id], 'user_with_ownership_ssi' => user.ms_id } }
        it 'returns the corresponding User and OrganizationCollection objects' do
          expect(subject.reviewer_display_names(work_doc, reviewers)).to match_array([user, org])
        end
      end
    end

    context 'download_reviewer_ssim is empty' do
      context 'user_with_ownership is an OrganizationCollection' do
        let(:work_doc) { { 'download_reviewer_ssim' => nil, 'user_with_ownership_ssi' => org.id } }
        it 'returns the organization' do
          expect(subject.reviewer_display_names(work_doc, reviewers)).to eq(org)
        end
      end

      context 'user_with_ownership is an individual user' do
        let(:work_doc) { { 'download_reviewer_ssim' => nil, 'user_with_ownership_ssi' => user.ms_id } }
        it 'returns the individual reviewers' do
          expect(subject.reviewer_display_names(work_doc, reviewers)).to eq(reviewers)
        end
      end
    end
  end
end
