require 'rails_helper'

RSpec.describe Morphosource::DownloadReviewerResolver do
  subject(:resolver) { described_class.new }

  let(:user)           { FactoryBot.create(:contributor) }
  let(:manager)        { FactoryBot.create(:contributor) }
  let(:other_manager)  { FactoryBot.create(:contributor) }
  let(:reviewer)       { FactoryBot.create(:contributor) }

  let(:organization)       { FactoryBot.create(:organization_collection, title: ['Org A'], depositor: user.ms_id) }
  let(:other_organization) { FactoryBot.create(:organization_collection, title: ['Org B'], depositor: user.ms_id) }

  # The resolver reads each organization's reviewers from Solr, so a manager change has to be
  # reindexed before it is visible to it.
  def add_manager(organization, new_manager)
    organization.managers << new_manager
    organization.managers_group.save!
    organization.update_index
  end

  def token_for(organization)
    "org_collection:#{organization.id}"
  end

  # Anything answering #download_reviewers is acceptable input; a double keeps the graph out of
  # the examples that are only about resolution.
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

    # The sharpest trap in this design: resolving only the organization that changed would
    # silently delete the other organization's managers from a shared media.
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

    it 'de-duplicates a user reachable both directly and through an organization' do
      add_manager(organization, manager)

      expect(resolver.call(identity(manager.ms_id, token_for(organization)))).to eq([manager.ms_id])
    end
  end

  describe 'memoization' do
    # Load-bearing rather than an optimization: a cart batch is typically many media from one
    # organization, and the lifecycle jobs resolve several hundred media per process.
    it 'loads one organization once across many media' do
      add_manager(organization, manager)
      media = Array.new(5) { identity(token_for(organization)) }

      expect(ActiveFedora::SolrService).to receive(:query).once.and_call_original

      expect(media.map { |m| resolver.call(m) }).to all(eq([manager.ms_id]))
    end
  end

  describe 'a dangling token' do
    let(:dangling) { 'org_collection:no-such-organization' }

    # The lifecycle jobs process media in batches and let exceptions raise, so a resolver that
    # raised would fail a whole batch and fail it again on every retry.
    it 'does not raise' do
      expect { resolver.call(identity(dangling)) }.not_to raise_error
    end

    # The negative case that protects the union rule: the fallback inspects the total, so a
    # token contributing nothing must not pull a system account in alongside a live result.
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
