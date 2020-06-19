# frozen_string_literal: true

# Generated via
# `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Morphosource::AccessControls::Permission do
  let(:args) { { name: 'agent_name', type: 'group', access: '' } }
  subject { Hydra::AccessControls::Permission.new(args).build_access(args[:access] ) }

  describe '#build_access' do
    context 'access is read' do
      before do
        args[:access] = 'read'
      end
      it 'returns ACL.Read' do
        expect(subject).to eq([Hydra::AccessControls::Mode.new(::ACL.Read)])
      end
      context 'access is edit' do
        before do
          args[:access] = 'edit'
        end
        it 'returns ACL.Write' do
          expect(subject).to eq([Hydra::AccessControls::Mode.new(::ACL.Write)])
        end
      end
      context 'access is discover' do
        before do
          args[:access] = 'discover'
        end
        it 'returns ACL.Discover' do
          expect(subject).to eq([Hydra::AccessControls::Mode.new(Hydra::ACL.Discover)])
        end
      end
      context 'access is download' do
        before do
          args[:access] = 'download'
        end
        it 'returns ACL.Download' do
          expect(subject).to eq([Hydra::AccessControls::Mode.new(Morphosource::ACL.Download)])
        end
      end
      context 'access is unknown' do
        before do
          args[:access] = 'oops'
        end
        it 'raises an argument error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
