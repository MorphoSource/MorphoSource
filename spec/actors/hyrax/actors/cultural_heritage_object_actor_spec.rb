require 'rails_helper'

RSpec.describe Hyrax::Actors::CulturalHeritageObjectActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }

  describe '#create' do
    let(:work) { CulturalHeritageObject.new }
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
    let(:work) { CulturalHeritageObject.new(title: [ 'Previous title' ]) }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
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
    let(:user_display_name) { 'Suzy Smith' }
    let(:depositor_display_name) { 'Bobby Jones' }
    let(:work) { CulturalHeritageObject.new }
    let(:collection_code_attr) { [ 'ABC' ] }
    let(:catalog_number_attr) { [ '123' ] }
    let(:short_title_attr) { [ 'My Short Title' ] }
    let(:identifier_attr) { [ 'zyx', 'cba'] }
    let(:vouchered_attr) { [ 'Yes' ] }
    let(:unvouchered_attr) { [ 'No' ] }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(User).to receive(:find_by_user_key).with(depositor.user_key) { depositor }
    end
    describe 'collection code, catalog number, and short title' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => catalog_number_attr,
                      'short_title' => short_title_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { "#{collection_code_attr.first}:#{catalog_number_attr.first} #{short_title_attr.first}" }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'collection code and catalog number but no short title' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => catalog_number_attr,
                      'short_title' => [],
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { "#{collection_code_attr.first}:#{catalog_number_attr.first}" }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'collection code and short title but no catalog number ' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => [],
                      'short_title' => short_title_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { "#{collection_code_attr.first} #{short_title_attr.first}" }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'catalog number and short title but no collection code' do
      let(:attrs) { { 'collection_code' => [],
                      'catalog_number' => catalog_number_attr,
                      'short_title' => short_title_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { "#{catalog_number_attr.first} #{short_title_attr.first}" }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'collection code but no catalog number or short title' do
      let(:attrs) { { 'collection_code' => collection_code_attr,
                      'catalog_number' => [],
                      'short_title' => [],
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { collection_code_attr.first }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'catalog number but no collection code or short title' do
      let(:attrs) { { 'collection_code' => [],
                      'catalog_number' => catalog_number_attr,
                      'short_title' => [],
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { catalog_number_attr.first }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'short title but no collection code or catalog number' do
      let(:attrs) { { 'collection_code' => [],
                      'catalog_number' => [],
                      'short_title' => short_title_attr,
                      'identifier' => identifier_attr,
                      'vouchered' => vouchered_attr } }
      let(:expected_title) { short_title_attr.first }
      specify { expect(subject.generated_title(env)).to eq(expected_title) }
    end
    describe 'neither collection nor catalog number nor short title' do
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
              before { depositor.display_name = depositor_display_name }
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: depositor.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'depositor does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: depositor.user_key)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
          describe 'depositor not present' do
            describe 'user has display name' do
              before { user.display_name = user_display_name }
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: user.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'user does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Vouchered', user: user.user_key)
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
              before { depositor.display_name = depositor_display_name }
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: depositor.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'depositor does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: depositor.user_key)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
          describe 'depositor not present' do
            describe 'user has display name' do
              before { user.display_name = user_display_name }
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: user.display_name)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
            describe 'user does not have display name' do
              let(:expected_title) do
                I18n.t('morphosource.fallback_object_title', voucher: 'Unvouchered', user: user.user_key)
              end
              specify { expect(subject.generated_title(env)).to eq(expected_title) }
            end
          end
        end
      end
    end
  end

end
