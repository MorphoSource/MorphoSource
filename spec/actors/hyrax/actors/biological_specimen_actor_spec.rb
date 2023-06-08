require 'rails_helper'

RSpec.describe Hyrax::Actors::BiologicalSpecimenActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  describe '#create' do
    let(:work) { BiologicalSpecimen.new(title: ['specimen'], visibility: 'restricted', vouchered: ["Yes"]) }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end
    it 'changes the title attribute' do
      expect { subject.create(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
    end

    describe 'adding view and edit access to linked teams' do

      context 'bso is created without organization' do
        before do
          env.attributes[:organization_id] = nil
        end
        it 'does not call #add_organization_team_access_for_po' do
          expect(subject).not_to receive(:add_organization_team_access_for_po).with(env)
          subject.create(env)
        end
      end

      context 'bso is created with organization through the submission process' do
        let(:organization) { Organization.new(title: ['org'], team_id: []) }

        before do
          organization.save
          env.attributes[:organization_id] = [organization.id]
        end

        context 'and organization without a linked team' do
          it 'does not call #get_groups' do
            expect(subject).to receive(:add_organization_team_access_for_po).with(env).and_call_original
            expect(subject).not_to receive(:get_groups)
            subject.create(env)
          end
        end

        context 'and organization with a linked team' do
          let(:user)      { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }
          let(:team)           { FactoryBot.create(:team, depositor: user.ms_id) }
          let(:team_manager)   { User.create(email: 'newmanager@test.com', password: 'password') }
          let(:team_depositor) { User.create(email: 'newdepositor@test.com', password: 'password') }
          let(:team_viewer)    { User.create(email: 'newviewer@test.com', password: 'password') }
          let(:team_editor)   { User.create(email: 'neweditor@test.com', password: 'password') }
          let(:team_downloader)   { User.create(email: 'downloader@test.com', password: 'password') }
          before do
            organization.team_id = [team.id]
            organization.save
            organization.reload

            team.create_collection_groups
            team.managers << team_manager
            team.depositors << team_depositor
            team.viewers << team_viewer
            team.editors << team_editor
            team.downloaders << team_downloader
            team.user_groups.each(&:save)

            subject.create(env)
            work.save
            work.reload
          end
          it 'updates the bso permissions' do
            expect(team_manager.can?(:read, work)).to be(true)
            expect(team_editor.can?(:read, work)).to be(true)
            expect(team_depositor.can?(:read, work)).to be(false)
            expect(team_viewer.can?(:read, work)).to be(false)
            expect(team_downloader.can?(:read, work)).to be(false)
            expect(team_manager.can?(:edit, work)).to be(true)
            expect(team_editor.can?(:edit, work)).to be(true)
            expect(team_depositor.can?(:edit, work)).to be(false)
            expect(team_viewer.can?(:edit, work)).to be(false)
            expect(team_downloader.can?(:edit, work)).to be(false)
          end
        end
      end
    end
  end

  describe '#update' do
    let(:work) { BiologicalSpecimen.new(title: [ 'Previous title' ]) }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { { "canonical_taxonomy"=>[] } }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end
    it 'changes the title attribute' do
      expect { subject.update(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
    end
  end

  describe '#generated_title' do
    let(:user) { FactoryBot.build(:user) }
    let(:ability) { Ability.new(user) }
    let(:depositor) { FactoryBot.build(:user) }
    let(:work) { BiologicalSpecimen.new }
    let(:collection_code_attr) { [ 'ABC' ] }
    let(:catalog_number_attr) { [ '123' ] }
    let(:identifier_attr) { [ 'zyx', 'cba'] }
    let(:vouchered_attr) { [ 'Yes' ] }
    let(:unvouchered_attr) { [ 'No' ] }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do

      allow(User).to receive(:find_by_user_key).with(depositor.user_key) { depositor }
    end
    describe 'collection code and catalog number' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => catalog_number_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { "#{collection_code_attr.first}:#{catalog_number_attr.first}" }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'collection code but no catalog number' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => [],
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { collection_code_attr.first }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'catalog number but no collection code' do
      let(:attrs) { { 'collection_code' => [],
                      'catalog_number' => catalog_number_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { catalog_number_attr.first }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'neither collection nor catalog number' do
      describe 'one identifier' do
        let(:attrs) { { 'collection_code' => [],
                        'catalog_number' => [],
                        'identifier' => [ identifier_attr.first ],
                        'vouchered' => vouchered_attr } }
        let(:expected_title) { identifier_attr.first }
        specify { expect(subject.generated_title(env)).to eq(expected_title) }
      end
      describe 'more than one identifier' do
        let(:attrs) { { 'collection_code' => [],
                        'catalog_number' => [],
                        'identifier' => identifier_attr,
                        'vouchered' => vouchered_attr } }
        let(:expected_title) { identifier_attr.sort.join(', ') }
        specify { expect(subject.generated_title(env)).to eq(expected_title) }
      end
      describe 'no identifier' do
        describe 'vouchered' do
          let(:attrs) { { 'collection_code' => [],
                          'catalog_number' => [],
                          'identifier' => [],
                          'vouchered' => vouchered_attr } }
          describe 'depositor present' do
            before { work.depositor = depositor.user_key }
            describe 'depositor has display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: depositor.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'depositor does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: depositor.email)
              end
              before do
                depositor.display_name = nil
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
          describe 'depositor not present' do
            describe 'user has display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: user.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'user does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: user.email)
              end
              before do
                user.display_name = nil
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
        end
        describe 'not vouchered' do
          let(:attrs) { { 'collection_code' => [],
                          'catalog_number' => [],
                          'identifier' => [],
                          'vouchered' => unvouchered_attr } }
          describe 'depositor present' do
            before { work.depositor = depositor.user_key }
            describe 'depositor has display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: depositor.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'depositor does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: depositor.email)
              end
              before do
                depositor.display_name = nil
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
          describe 'depositor not present' do
            describe 'user has display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: user.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'user does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: user.email)
              end
              before do
                user.display_name = nil
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
        end
      end
    end
  end
  describe "#check_canonical_taxonomy" do
    let(:work) { BiologicalSpecimen.new(title: [ 'Test title' ]) }
    let(:ability) { Ability.new(User.new) }
    let(:canonical_taxonomy_id) { ["3b5918592"] }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }


    before do
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    context 'the canonical taxonomy is dissociated from the work' do
      let(:attrs) { {"canonical_taxonomy"=> canonical_taxonomy_id, "taxonomy_id"=> []} }

      it "clears the canonical_taxonomy attribute" do
        expect(subject.send(:check_canonical_taxonomy, env)).to eq('')
      end
    end

    context 'a taxonomy other than the canonical taxonomy is dissociated' do
      let(:attrs) { {"canonical_taxonomy"=> canonical_taxonomy_id, "taxonomy_id"=>[canonical_taxonomy_id.first]} }

      it "keeps the canonical_taxonomy attribute value" do
        expect(subject.send(:check_canonical_taxonomy, env)).to eq(canonical_taxonomy_id.first)
      end
    end

    context 'there is no canonical taxonomy selected' do
      let(:attrs) { {"canonical_taxonomy"=> [], "taxonomy_id"=>["def456"]} }

      it "canonical taxonomy remains blank" do
        expect(subject.send(:check_canonical_taxonomy, env)).to eq('')
      end
    end
  end
end
