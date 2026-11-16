require 'rails_helper'

RSpec.describe Morphosource::MediaReviewerBlock do
  subject(:block) { described_class.new(media) }

  let(:owner_user) { FactoryBot.create(:contributor) }
  let(:reviewer)   { FactoryBot.create(:contributor) }
  let(:manager)    { FactoryBot.create(:contributor) }
  let(:media)      { FactoryBot.create(:media, owner: owner_user.ms_id, depositor: owner_user.ms_id) }
  let(:organization) do
    FactoryBot.create(:organization_collection, title: ['Eligible Org'], depositor: owner_user.ms_id,
                                                reviews_object_media_downloads: true)
  end
  let(:other_organization) do
    FactoryBot.create(:organization_collection, title: ['Second Org'], depositor: owner_user.ms_id,
                                                reviews_object_media_downloads: true)
  end
  let(:ineligible_organization) do
    FactoryBot.create(:organization_collection, title: ['Ineligible Org'], depositor: owner_user.ms_id)
  end
  let(:other_ineligible_organization) do
    FactoryBot.create(:organization_collection, title: ['Other Ineligible Org'], depositor: owner_user.ms_id)
  end

  def add_manager(organization, new_manager)
    organization.managers << new_manager
    organization.managers_group.save!
    organization.update_index
  end

  def with_object_organizations(*organizations)
    allow(media).to receive(:organizations).and_return(organizations)
  end

  def store_organization_mode(*organizations)
    with_object_organizations(*organizations)
    media.download_reviewer_mode = 'object_organization'
    media.save!(validate: false)
  end

  describe 'source' do
    it 'is :record_users when the record names live reviewers' do
      media.update!(record_download_reviewer_users: [reviewer.ms_id])
      with_object_organizations

      expect(block.source).to eq(:record_users)
      expect(block.reviewer_ms_ids).to eq([reviewer.ms_id])
    end

    it 'is :owner_user when the record list is blank and a User owns the media' do
      with_object_organizations

      expect(block.source).to eq(:owner_user)
      expect(block.reviewer_ms_ids).to eq([owner_user.ms_id])
      expect(block.owner_label).to eq(owner_user.name_or_email)
      expect(block.owner_organization?).to be false
    end

    context 'with an Owner Organization that is not an Object Organization' do
      let(:media) { FactoryBot.create(:media, owner: other_organization.id, depositor: owner_user.ms_id) }

      it 'is :owner_organization and names the Owner Organization' do
        add_manager(other_organization, manager)
        with_object_organizations(organization)

        expect(block.source).to eq(:owner_organization)
        expect(block.reviewer_ms_ids).to eq([manager.ms_id])
        expect(block.source_organization_titles).to eq(['Second Org'])
        expect(block.owner_label).to eq('Second Org')
        expect(block.owner_organization?).to be true
      end
    end

    it 'is :object_organizations and names each organization' do
      add_manager(organization, manager)
      add_manager(other_organization, reviewer)
      store_organization_mode(organization, other_organization)

      expect(block.source).to eq(:object_organizations)
      expect(block.reviewer_ms_ids).to match_array([manager.ms_id, reviewer.ms_id])
      expect(block.source_organization_titles).to eq(['Eligible Org', 'Second Org'])
    end

    describe ':staff' do
      let(:batch_ms_id) { User.batch_user.ms_id }

      it 'applies when the Object Organization has no managers' do
        store_organization_mode(organization)

        expect(block.source).to eq(:staff)
        expect(block.reviewer_ms_ids).to eq([batch_ms_id])
      end

      it 'applies in object_organization mode with zero Object Organizations' do
        store_organization_mode

        expect(block.source).to eq(:staff)
        expect(block.reviewer_ms_ids).to eq([batch_ms_id])
      end

      it 'applies when no record-list ms_id names a live User' do
        media.update!(record_download_reviewer_users: ['dead-ms-id'])
        with_object_organizations

        expect(block.source).to eq(:staff)
        expect(block.reviewer_ms_ids).to eq([batch_ms_id])
      end
    end

    it 'has a via line for every source the block can report' do
      sources = %i[object_organizations record_users owner_user owner_organization staff]

      sources.each do |source|
        expect(I18n.exists?("morphosource.reviewers.media.via.#{source}")).to be(true), source.to_s
      end
    end
  end

  describe 'organization mode availability' do
    it 'allows entry when every Object Organization is eligible' do
      with_object_organizations(organization, organization)

      expect(block.can_enter_organization_mode?).to be true
      expect(block.organization_radio_disabled?).to be false
      expect(block.object_organizations).to eq([organization])
    end

    it 'names every ineligible organization and disables the radio' do
      with_object_organizations(organization, ineligible_organization, other_ineligible_organization)

      expect(block.organization_radio_disabled?).to be true
      expect(block.blocked_organization_titles).to eq(['Ineligible Org', 'Other Ineligible Org'])
    end

    it 'disables the radio when there are no Object Organizations' do
      with_object_organizations

      expect(block.organization_radio_disabled?).to be true
      expect(block.blocked_organizations).to be_empty
    end

    it 'keeps the radio enabled and checked on a Grandfathered media' do
      store_organization_mode(ineligible_organization)

      expect(block.grandfathered?).to be true
      expect(block.organization_radio_disabled?).to be false
      expect(block.checked_mode).to eq('object_organization')
    end

    it 'treats stored organization mode with zero Object Organizations as Grandfathered' do
      store_organization_mode

      expect(block.grandfathered?).to be true
      expect(block.blocked_organizations).to be_empty
    end
  end

  describe 'after a refused save' do
    it 'reads the stored record and never checks a disabled organization radio' do
      media.update!(record_download_reviewer_users: [reviewer.ms_id])
      media.download_reviewer_mode = 'object_organization'
      # The work factory stubs single-argument finds to return the in-memory instance.
      stored = ActiveFedora::Base.find(media.id, cast: true)
      allow(stored).to receive(:organizations).and_return([ineligible_organization])
      expect(Media).to receive(:find).with(media.id).and_return(stored)

      expect(block.source).to eq(:record_users)
      expect(block.checked_mode).to eq('record_users')
    end

    it 'does not reload an unchanged record' do
      with_object_organizations
      expect(Media).not_to receive(:find)

      block
    end
  end

  it 'reads an untitled Owner Organization as the owner in the via line' do
    with_object_organizations
    allow(media).to receive(:download_reviewer_route).and_return([:owner_organization, ['org_collection:untitled']])
    resolution = Morphosource::DownloadReviewerResolver::Resolution.new(ms_ids: [owner_user.ms_id], fallback: false)
    allow_any_instance_of(Morphosource::DownloadReviewerResolver).to receive(:resolve).and_return(resolution) # rubocop:disable RSpec/AnyInstance

    expect(block.via_source).to eq(:owner_user)
  end

  it 'looks the owner up once' do
    with_object_organizations
    expect(media).to receive(:user_with_ownership).once.and_call_original

    block.owner_label
    block.owner_organization?
    block.owner_label
  end

  it 'falls back to no owner label when the owner cannot be resolved' do
    with_object_organizations
    allow(media).to receive(:user_with_ownership).and_return(['no-such-owner'])

    expect(block.owner_label).to be_nil
  end
end
