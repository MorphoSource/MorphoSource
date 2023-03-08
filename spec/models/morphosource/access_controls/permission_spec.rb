# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::AccessControls::Permission do
  let(:described_class) { Hydra::AccessControls::Permission }
  let(:args)            { { name: 'agent_name', type: 'group', access: '' } }
  subject               { described_class.new(args).build_access(args[:access] ) }

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

  describe "URI escaping" do
    let(:user_permission)   { described_class.new(type: 'person', name: 'john doe', access: 'read') }
    let(:user_permission2)  { described_class.new(type: 'person', name: 'john%20doe', access: 'read') }
    let(:user_permission3)  { described_class.new(type: 'person', name: 'john+doe', access: 'read') }
    let(:group_permission)  { described_class.new(type: 'group', name: 'hydra devs', access: 'read') }
    let(:group_permission2) { described_class.new(type: 'group', name: 'hydra%20devs', access: 'read') }
    let(:group_permission3) { described_class.new(type: 'group', name: 'hydra+devs', access: 'read') }

    it "should escape agent when building" do
      expect(user_permission.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john%20doe'
      expect(user_permission2.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john%2520doe'
      expect(user_permission3.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/person#john+doe'
      expect(group_permission.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra%20devs'
      expect(group_permission2.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra%2520devs'
      expect(group_permission3.agent.first.rdf_subject.to_s).to eq 'http://projecthydra.org/ns/auth/group#hydra+devs'
    end

    it "should unescape agent when parsing" do
      expect(user_permission.agent_name).to eq 'john doe'
      expect(user_permission2.agent_name).to eq 'john%20doe'
      expect(user_permission3.agent_name).to eq 'john+doe'
      expect(group_permission.agent_name).to eq 'hydra devs'
      expect(group_permission2.agent_name).to eq 'hydra%20devs'
      expect(group_permission3.agent_name).to eq 'hydra+devs'
    end

    context 'with a User instance passed as :name argument' do
      let(:permission)  { described_class.new(type: 'person', name: user, access: 'read') }
      let(:user)        { FactoryBot.build(:user, email: 'user@example.com') }

      it "uses string and escape agent when building" do
        expect(permission.agent.first.rdf_subject.to_s).to eq "http://projecthydra.org/ns/auth/person##{user.ms_id}"
      end
    end
  end
end
