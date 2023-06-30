# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationPresenter do
  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:institution_code).to(:solr_document) }
  it { is_expected.to delegate_method(:address).to(:solr_document) }
  it { is_expected.to delegate_method(:city).to(:solr_document) }
  it { is_expected.to delegate_method(:state_province).to(:solr_document) }
  it { is_expected.to delegate_method(:postal_code).to(:solr_document) }
  it { is_expected.to delegate_method(:country).to(:solr_document) }

  describe 'linked_team' do
    let!(:team)                 { Collection.create(title: ['collection'], collection_type_gid: team_collection_type.gid) }

    context 'there is no linked team' do
      before do
        allow(subject).to receive(:team_id).and_return(nil)
      end
      it 'returns nil' do
        expect(subject.linked_team).to eq(nil)
      end
    end
    context 'there is a linked team' do
      before do
        allow(subject).to receive(:team_id).and_return([team.id])
      end
      it 'returns a link to the team' do
        expect(subject.linked_team).to eq("<a href=\"/teams/000200000\">collection</a>")
      end
    end
  end
end
