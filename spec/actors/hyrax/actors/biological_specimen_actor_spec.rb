require 'rails_helper'

RSpec.describe Hyrax::Actors::BiologicalSpecimenActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  describe '#create' do
    let(:work) { BiologicalSpecimen.new }
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
