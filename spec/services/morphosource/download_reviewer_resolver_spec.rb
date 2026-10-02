require 'rails_helper'

RSpec.describe Morphosource::DownloadReviewerResolver do
  subject(:resolver) { described_class.new }

  let(:user)           { FactoryBot.create(:contributor) }
  let(:manager)        { FactoryBot.create(:contributor) }
  let(:other_manager)  { FactoryBot.create(:contributor) }
  let(:reviewer)       { FactoryBot.create(:contributor) }

  let(:organization)       { FactoryBot.create(:organization_collection, title: ['Org A'], depositor: user.ms_id) }
  let(:other_organization) { FactoryBot.create(:organization_collection, title: ['Org B'], depositor: user.ms_id) }

  # The resolver reads Solr, so reindex after changing managers.
  def add_manager(organization, new_manager)
    organization.managers << new_manager
    organization.managers_group.save!
    organization.update_index
  end

  def token_for(organization)
    "org_collection:#{organization.id}"
  end

  def identity(*download_reviewers)
    instance_double(Media, download_reviewers: download_reviewers)
  end

  describe 'accepted input' do
    it 'accepts a Media' do
      media = FactoryBot.create(:media, owner: user.ms_id, depositor: user.ms_id)

      expect(resolver.call(media)).to eq([user.ms_id])
    end

    it 'accepts a SolrDocument' do
      document = SolrDocument.new('download_reviewers_ssim' => [user.ms_id])

      expect(resolver.call(document)).to eq([user.ms_id])
    end
  end

  describe 'resolution' do
    it 'returns stored ms_ids that name a live User' do
      expect(resolver.call(identity(reviewer.ms_id, user.ms_id))).to match_array([reviewer.ms_id, user.ms_id])
    end

    it "follows a token to the organization's reviewers" do
      add_manager(organization, manager)

      expect(resolver.call(identity(token_for(organization)))).to eq([manager.ms_id])
    end

    it 'returns the union when a media names two organizations' do
      add_manager(organization, manager)
      add_manager(other_organization, other_manager)

      expect(resolver.call(identity(token_for(organization), token_for(other_organization))))
        .to match_array([manager.ms_id, other_manager.ms_id])
    end

    it 'resolves a mixed list of ms_ids and tokens' do
      add_manager(organization, manager)

      expect(resolver.call(identity(reviewer.ms_id, token_for(organization))))
        .to match_array([reviewer.ms_id, manager.ms_id])
    end

    it "drops an organization reviewer whose User was deleted after the organization was indexed" do
      add_manager(organization, manager)
      add_manager(organization, other_manager)
      other_manager.delete

      expect(resolver.call(identity(token_for(organization)))).to eq([manager.ms_id])
    end

    it 'de-duplicates a user reachable both directly and through an organization' do
      add_manager(organization, manager)

      expect(resolver.call(identity(manager.ms_id, token_for(organization)))).to eq([manager.ms_id])
    end
  end

  describe 'memoization' do
    it 'loads one organization once across many media' do
      add_manager(organization, manager)
      media = Array.new(5) { identity(token_for(organization)) }

      expect(ActiveFedora::SolrService).to receive(:query).once.and_call_original

      expect(media.map { |m| resolver.call(m) }).to all(eq([manager.ms_id]))
    end

    def legacy_documents(owner_id)
      Array.new(5) do
        SolrDocument.new('has_model_ssim' => ['Media'], 'user_with_ownership_ssi' => owner_id)
      end
    end

    it 'classifies and resolves a shared legacy organization owner once' do
      add_manager(organization, manager)
      documents = legacy_documents(organization.id)

      expect(OrganizationCollection).to receive(:exists?).with(organization.id).once.and_call_original
      expect(ActiveFedora::SolrService).to receive(:query).twice.and_call_original

      expect(documents.map { |document| resolver.call(document) }).to all(eq([manager.ms_id]))
    end

    it 'caches the non-organization classification of a User owner' do
      documents = legacy_documents(user.ms_id)

      expect(ActiveFedora::SolrService).to receive(:query).once.and_call_original

      expect(documents.map { |document| resolver.call(document) }).to all(eq([user.ms_id]))
    end

    it 'caches a missing owner while retaining the batch User fallback' do
      documents = legacy_documents('missing-owner')
      batch_user_ms_id = User.batch_user.ms_id

      expect(ActiveFedora::SolrService).to receive(:query).once.and_call_original

      expect(documents.map { |document| resolver.call(document) }).to all(eq([batch_user_ms_id]))
    end

    it 'keeps a zero-manager organization as an organization with the batch User fallback' do
      documents = legacy_documents(organization.id)
      batch_user_ms_id = User.batch_user.ms_id

      expect(ActiveFedora::SolrService).to receive(:query).twice.and_call_original

      expect(documents.map { |document| resolver.call(document) }).to all(eq([batch_user_ms_id]))
    end

    it 'classifies the owner again in a new resolver operation' do
      document = legacy_documents(user.ms_id).first

      expect(OrganizationCollection).to receive(:exists?).with(user.ms_id).twice.and_call_original

      expect(resolver.call(document)).to eq([user.ms_id])
      expect(described_class.new.call(document)).to eq([user.ms_id])
    end
  end

  describe 'a dangling token' do
    let(:dangling) { 'org_collection:no-such-organization' }

    it 'does not raise' do
      expect { resolver.call(identity(dangling)) }.not_to raise_error
    end

    it 'contributes nothing beside a resolvable organization' do
      add_manager(organization, manager)

      expect(resolver.call(identity(token_for(organization), dangling))).to eq([manager.ms_id])
    end
  end

  describe 'the batch User fallback' do
    let(:batch_user_ms_id) { User.batch_user.ms_id }

    it 'applies when an organization in manager mode has no managers' do
      expect(resolver.call(identity(token_for(organization)))).to eq([batch_user_ms_id])
    end

    it 'applies when a media in object_organization mode has no Object Organizations' do
      expect(resolver.call(identity)).to eq([batch_user_ms_id])
    end

    it 'applies when no stored ms_id names a live User' do
      expect(resolver.call(identity('dead-ms-id', 'another-dead-ms-id'))).to eq([batch_user_ms_id])
    end

    it "applies when an organization's indexed reviewers have all been deleted" do
      add_manager(organization, manager)
      manager.delete

      expect(resolver.call(identity(token_for(organization)))).to eq([batch_user_ms_id])
    end

    it 'applies when every token is dangling' do
      expect(resolver.call(identity('org_collection:gone'))).to eq([batch_user_ms_id])
    end

    it 'looks the batch User up once across many media' do
      media = Array.new(5) { identity('dead-ms-id') }

      expect(User).to receive(:batch_user).once.and_call_original

      media.each { |m| resolver.call(m) }
    end

    it 'does not apply when anything at all resolves' do
      add_manager(organization, manager)

      expect(resolver.call(identity(token_for(organization)))).not_to include(batch_user_ms_id)
    end
  end
end
