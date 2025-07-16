# frozen_string_literal: true

# Generated via
# `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Organization do

  it_behaves_like 'a Morphosource work'

  it "is valid with valid attributes" do
      subject.title = ['foo']
      subject.institution_code = ['foo']
      subject.address = ['foo']
      subject.city = ['foo']
      subject.state_province = ['foo']
      subject.postal_code = ['foo']
      subject.country = ['foo']
      subject.institution_name = ['foo']
      subject.collection_code = ['foo']
      subject.team_id = ['foo']
      subject.date_managed = 'foo'
      # permissions defaults metadata
      subject.download_permission = ['foo']
      subject.download_reviewer = ['foo']
      subject.agreement_uri = ['foo']
      subject.rights_statement = ['foo']
      subject.permits_commercial_use = ['foo']
      subject.permits_3d_use = ['foo']
      subject.rights_holder = ['foo']
      expect(subject).to be_valid
  end

  it "is not valid without required field - title" do
    subject.title = nil
    subject.institution_code = ['foo']
    subject.description = ['foo']
    subject.address = ['foo']
    subject.city = ['foo']
    subject.state_province = ['foo']
    subject.postal_code = ['foo']
    subject.country = ['foo']
    subject.date_managed = 'foo'
    # permissions defaults metadata
    subject.download_permission = ['foo']
    subject.download_reviewer = ['foo']
    subject.agreement_uri = ['foo']
    subject.rights_statement = ['foo']
    subject.permits_commercial_use = ['foo']
    subject.permits_3d_use = ['foo']
    subject.rights_holder = ['foo']
    expect(subject).to_not be_valid
  end

  describe "valid work relationships" do
    it "has no valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
    end

    it "has Device, BiologicalSpecimen, and CulturalHeritageObject as valid children" do
      expect(subject.valid_child_concerns).to match_array([Device])
    end
  end

  describe "instance" do
    let(:team)                  { Collection.create(title: ['team'], collection_type_gid: team_collection_type.to_global_id) }

    subject { Organization.create({
        title: ['American Museum of Natural History'],
        institution_code: ['AMNH'],
        description: ['A sample description'],
        address: ['Central Park West'],
        city: ['New York City'],
        state_province: ['New York'],
        postal_code: ['12345'],
        country: ['United States'],
        team_id: [team.id]
      })
    }

    it "creates with correct title" do
      expect(subject.title.first).to eq('American Museum of Natural History')
    end

    it "creates with correct institution_code" do
      expect(subject.institution_code.first).to eq('AMNH')
    end

    it "creates with correct description" do
      expect(subject.description.first).to eq('A sample description')
    end

    it "creates with correct address" do
      expect(subject.address.first).to eq('Central Park West')
    end

    it "creates with correct city" do
      expect(subject.city.first).to eq('New York City')
    end

    it "creates with correct state_province" do
      expect(subject.state_province.first).to eq('New York')
    end

    it "creates with correct postal_code" do
      expect(subject.postal_code.first).to eq('12345')
    end

    it "creates with correct country" do
      expect(subject.country.first).to eq('United States')
    end

    it "creates with correct team id" do
      expect(subject.team_id.first).to eq(team.id)
    end

    describe "valid work relationships" do

      it "has no valid parents" do
        expect(subject.valid_parent_concerns).to match_array([])
      end

      it "has Device, BiologicalSpecimen, and CulturalHeritageObject as valid children" do
        expect(subject.valid_child_concerns).to match_array([Device])
      end
    end

    describe 'team-related instance methods' do
      let(:team)                  { Collection.create(id: 'teamid', title: ['Team'], collection_type_gid: team_collection_type.to_global_id, depositor: 'abcdef') }
      let(:specimen1)             { BiologicalSpecimen.create(title: ['title'], vouchered: ["Yes"], organization_id: [subject.id]) }
      let(:specimen2)             { BiologicalSpecimen.create(title: ['title'], vouchered: ["No"], organization_id: [subject.id]) }

      before do
        subject.team_id = [team.id]
        subject.save
        specimen1.save
        specimen2.save
        allow(Collection).to receive(:find).with(team.id).and_return(team)
      end

      describe '#team' do
        it 'returns the linked team' do
          expect(subject.team).to eq(team)
        end
      end

      describe '#specimens, #outside_specimens' do
        before do
          specimen1.member_of_collections << team
        end

        it '#specimens returns child specimens' do
          expect(subject.specimens).to match_array([specimen1, specimen2])
        end

        it '#outside_specimens returns specimens not owned by team' do
          expect(subject.outside_specimens).to match_array([specimen2])
        end
      end

      describe '#media, #outside_media' do
        let(:media1)          { Media.create(title: ['title']) }
        let(:media2)          { Media.create(title: ['title']) }
        let(:media3)          { Media.create(title: ['title']) }
        let(:device)          { Device.create(title: ['title'], modality: ['Photogrammetry']) }
        let(:imagingEvent)    { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen1.id], ie_modality: device.modality) }
        let(:imagingEvent2)   { ImagingEvent.create(title: ['title'], device_id: [device.id], physical_object_id: [specimen2.id], ie_modality: device.modality) }
        let(:processingEvent) { ProcessingEvent.new(title: ['title']) }

        before do
          imagingEvent.ordered_members << media1
          imagingEvent.save
          media1.ordered_members << processingEvent
          media1.save
          processingEvent.ordered_members << media2
          processingEvent.save
          media2.save

          imagingEvent2.ordered_members << media3
          imagingEvent2.save

          media3.member_of_collections << team
          media3.save
          team.save
          [media1, media2, media3].each(&:reload)
        end

        it '#media returns all descendant media' do
          expect(subject.media).to match_array([media1, media2, media3])
        end

        it '#outside_media returns specimens not owned by team' do
          expect(subject.outside_media).to match_array([media1, media2])
        end
      end
    end
  end

  describe 'record_original_team' do
    let(:team1)         { Collection.create(title: ['team1'], collection_type_gid: team_collection_type.to_global_id) }
    let(:team2)         { Collection.create(title: ['team2'], collection_type_gid: team_collection_type.to_global_id) }
    let(:project)         { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id) }
    let(:organization) { Organization.create(title: ['org'], team_id: [team1.id]) }

    before do
      project.member_of_collections << team1
      project.save
    end

    context 'updating a team' do
      it 'records the original team' do
        expect(organization).to receive(:record_original_team).and_wrap_original do |m, *args|
          result = m.call(*args)
          expect(result).to match_array([team1, project])
          result
        end
        organization.update(team_id: [team2.id])
        expect(organization.team).to eq(team2)
      end
    end
  end

  describe 'record_date_managed' do
    let(:user)          { FactoryBot.create(:contributor) }

    context 'organization does not have a team' do
      let!(:organization) { FactoryBot.create(:organization, depositor: user.ms_id) }

      context 'organization has a date_managed' do
        before do
          organization.date_managed = Date.today
        end
        it 'removes date_managed' do
          expect(organization.date_managed).to eq(Date.today)
          expect { organization.record_date_managed }.to change { organization.date_managed }.from(Date.today).to(nil)
        end
      end
      context 'organization does not have a date_managed' do
        it 'does not change date_managed' do
          expect(organization.date_managed).to be_nil
          expect { organization.record_date_managed }.not_to change { organization.date_managed }
        end
      end
    end
    context 'organization has a team' do
      let!(:team)         { FactoryBot.create(:collection, collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
      let!(:organization) { FactoryBot.create(:organization, depositor: user.ms_id, team_id: [team.id]) }
      before do
        team.create_collection_groups
      end
      context 'team does not have managers' do
        before do
          team.managers_group.users = []
          team.managers_group.save!
        end
        context 'team has a date_managed' do
          before do
            organization.date_managed = Date.today
          end
          it 'removes date_managed' do
            expect(organization.date_managed).to eq(Date.today)
            expect { organization.record_date_managed }.to change { organization.date_managed }.from(Date.today).to(nil)
          end
        end
        context 'collection does not have a date_managed' do
          it 'does not change date_managed' do
            expect(organization.date_managed).to be_nil
            expect { organization.record_date_managed }.not_to change { organization.date_managed }
          end
        end
      end
      context 'collection has managers' do
        context 'collection has a date_managed' do
          before do
            organization.date_managed = Date.today
          end
          it 'does not change the date_managed' do
            expect(organization.date_managed).to eq(Date.today)
            expect { organization.record_date_managed }.not_to change { organization.date_managed }
          end
        end
        context 'collections does not have a date_managed' do
          it 'adds a date_managed' do
            expect(organization.date_managed).to be_nil
            expect { organization.record_date_managed }.to change { organization.date_managed }.from(nil).to(Date.today)
          end
        end
      end
    end
  end
end
