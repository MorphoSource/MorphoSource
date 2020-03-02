# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::LinkedTeamsHelper, type: :helper do
  describe '#unlinked_organizations' do
    let!(:org1) { Organization.create(title: ['org1']) }
    let!(:org2) { Organization.create(title: ['org2']) }
    let!(:org3) { Organization.create(title: ['org3'], team_id: ['1']) }
    let!(:org4) { Organization.create(title: ['org4'], team_id: ['2']) }
    let!(:org5) { Organization.create(title: ['org5'], team_id: ['3']) }

    it 'returns only organizations that are not linked to a team' do
      expect(helper.unlinked_organizations).to match_array([[org1.title.first, org1.id], [org2.title.first, org2.id]])
    end
  end
end
