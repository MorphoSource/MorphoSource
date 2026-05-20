# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::IiifManifestPresenter do
  describe '#file_set?' do
    context 'with a Valkyrie FileSet (has_model_ssim: Hyrax::FileSet)' do
      subject { described_class.new(SolrDocument.new('has_model_ssim' => ['Hyrax::FileSet'])) }

      it { is_expected.to be_file_set }
    end

    context 'with an AF FileSet (has_model_ssim: FileSet)' do
      subject { described_class.new(SolrDocument.new('has_model_ssim' => ['FileSet'])) }

      it { is_expected.to be_file_set }
    end

    context 'with a Media work' do
      subject { described_class.new(SolrDocument.new('has_model_ssim' => ['Media'])) }

      it { is_expected.not_to be_file_set }
    end
  end

  describe '#member_ids' do
    let(:model) { SolrDocument.new('valkyrie_member_ids_ssim' => ['val-1', 'val-2']) }
    subject { described_class.new(model) }

    before do
      allow(Hyrax::SolrDocument::OrderedMembers)
        .to receive(:decorate).and_return(double(ordered_member_ids: ['af-1']))
    end

    it 'includes both AF ordered member ids and Valkyrie member ids' do
      expect(subject.member_ids).to include('af-1', 'val-1', 'val-2')
    end

    it 'deduplicates ids present in both' do
      allow(Hyrax::SolrDocument::OrderedMembers)
        .to receive(:decorate).and_return(double(ordered_member_ids: ['val-1']))
      expect(subject.member_ids).to eq(['val-1', 'val-2'])
    end
  end

  describe 'DisplayImagePresenter' do
    subject(:presenter) { described_class::DisplayImagePresenter.new(model) }

    describe '#file_set_identifier' do
      context 'with an AF FileSet (has access_control_id)' do
        let(:model) { SolrDocument.new('has_model_ssim' => ['FileSet']) }

        before { allow(model).to receive(:access_control_id).and_return('af-acl-uuid') }

        it 'returns access_control_id' do
          expect(presenter.file_set_identifier).to eq('af-acl-uuid')
        end
      end

      context 'with a Valkyrie FileSet (no access_control_id)' do
        let(:model) { SolrDocument.new('has_model_ssim' => ['Hyrax::FileSet'], 'id' => 'valkyrie-uuid') }

        before { allow(model).to receive(:access_control_id).and_return(nil) }

        it 'falls back to model.id' do
          expect(presenter.file_set_identifier).to eq('valkyrie-uuid')
        end
      end
    end

    describe '#parent_work' do
      context 'with an AF FileSet (has_model_ssim: FileSet)' do
        let(:model) { SolrDocument.new('has_model_ssim' => ['FileSet'], 'id' => 'af-fs-id') }
        let(:parent_media) { instance_double(Media) }

        before do
          allow(::FileSet).to receive(:find).with('af-fs-id').and_return(
            instance_double(::FileSet, parent: parent_media)
          )
        end

        it 'returns parent via ::FileSet.find' do
          expect(presenter.parent_work).to eq(parent_media)
        end
      end

      context 'with a Valkyrie FileSet (has_model_ssim: Hyrax::FileSet)' do
        let(:model) { SolrDocument.new('has_model_ssim' => ['Hyrax::FileSet'], 'id' => 'val-fs-id') }
        let(:parent_media) { instance_double(Media) }

        before do
          allow(Hyrax::FileSet).to receive(:find).with('val-fs-id').and_return(
            instance_double(Hyrax::FileSet, parent: parent_media)
          )
        end

        it 'returns parent via Hyrax::FileSet.find' do
          expect(presenter.parent_work).to eq(parent_media)
        end
      end
    end
  end
end
