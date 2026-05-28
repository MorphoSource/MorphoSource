# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::FileSet do
  describe '#parent' do
    let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set) }
    let(:parent_work) { instance_double(Media, is_remote_backed?: false, has_remote_manifest?: false, remote_manifest_url: nil, remote_origin_url: nil) }

    before do
      allow(file_set).to receive(:member_of).and_return([parent_work])
    end

    it 'returns the first member_of result' do
      expect(file_set.parent).to eq(parent_work)
    end

    it 'memoizes: member_of is called only once across multiple delegating methods' do
      file_set.is_remote_backed?
      file_set.has_remote_manifest?
      file_set.remote_manifest_url
      file_set.remote_origin_url
      expect(file_set).to have_received(:member_of).once
    end
  end

  describe '#is_remote_backed?' do
    let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set) }

    context 'when parent is remote-backed' do
      before { allow(file_set).to receive(:member_of).and_return([double('parent', is_remote_backed?: true)]) }

      it { expect(file_set.is_remote_backed?).to be true }
    end

    context 'when there is no parent' do
      before { allow(file_set).to receive(:member_of).and_return([]) }

      it { expect(file_set.is_remote_backed?).to be false }
    end
  end

  describe '#has_remote_manifest?' do
    let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set) }

    context 'when parent has a remote manifest' do
      before { allow(file_set).to receive(:member_of).and_return([double('parent', has_remote_manifest?: true)]) }

      it { expect(file_set.has_remote_manifest?).to be true }
    end

    context 'when there is no parent' do
      before { allow(file_set).to receive(:member_of).and_return([]) }

      it { expect(file_set.has_remote_manifest?).to be false }
    end
  end
end
