require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team') }
  let!(:team)                 { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid) }
  let(:organization)          { Organization.new(title: ['Organization Title']) }

  describe 'team' do
    describe 'linked organization' do
      context 'there is no linked organization' do
        it 'does not have linked organization metadata' do
          subject = SolrDocument.find(team.id)
          expect(subject['linked_organization_tesim']).to be_nil
        end
      end

      context 'an organization is linked' do
        before do
          organization.team_id = [team.id]
          organization.save
        end

        it 'has linked organization metadata' do
          subject = SolrDocument.find(team.id)
          expect(subject['linked_organization_tesim']).to eq(organization.title.to_a)
        end

        context 'an organization is unlinked' do
          before do
            organization.team_id = []
            organization.save
          end

          it 'has does not have linked organization metadata' do
            subject = SolrDocument.find(team.id)
            expect(subject['linked_organization_tesim']).to be_nil
          end
        end

        context 'an organization is linked to another team' do
          let!(:another_team) { Collection.create(title: ['Another Team'], collection_type_gid: team_collection_type.gid)}
          let(:another_doc)   { SolrDocument.find(another_team.id) }
          before do
            organization.team_id = [another_team.id]
            organization.save
          end

          it 'does not have linked organization metadata' do
            subject = SolrDocument.find(team.id)
            expect(subject['linked_organization_tesim']).to be_nil
          end

          it 'is linked in the other collections solr' do
            subject = SolrDocument.find(team.id)
            expect(another_doc['linked_organization_tesim']).to eq(organization.title.to_a)
          end
        end
      end
    end
  end

  describe 'project' do
    let!(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
    let!(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid) }

    before do
      project.member_of_collections << team
      project.save
    end

    describe 'linked organization' do
      context 'there is no linked organization' do

        it 'does not have linked organization metadata' do
          subject = SolrDocument.find(project.id)
          expect(subject['linked_organization_tesim']).to be_nil
        end
      end

      context 'there is a linked organization' do
        before do
          organization.team_id = [team.id]
          organization.save
        end

        it 'has linked organization metadata' do
          subject = SolrDocument.find(project.id)
          expect(subject['linked_organization_tesim']).to eq(organization.title.to_a)
        end
      end

      context 'an organization is linked' do
        before do
          organization.team_id = [team.id]
          organization.save
        end

        it 'has linked organization metadata' do
          subject = SolrDocument.find(project.id)
          expect(subject['linked_organization_tesim']).to eq(organization.title.to_a)
        end

        context 'the linked organization is removed' do
          before do
            organization.team_id = []
            organization.save
          end

          it 'does not have linked organization metadata' do
            subject = SolrDocument.find(project.id)
            expect(subject['linked_organization_tesim']).to be_nil
          end
        end

        context 'an organization is linked to another team' do
          let!(:another_team) { Collection.create(title: ['Another Team'], collection_type_gid: team_collection_type.gid)}
          before do
            organization.team_id = [another_team.id]
            organization.save
          end

          it 'does not have linked organization metadata' do
            subject = SolrDocument.find(project.id)
            expect(subject['linked_organization_tesim']).to be_nil
          end

          it 'is linked in the other collections solr' do
            subject = SolrDocument.find(another_team.id)
            expect(subject['linked_organization_tesim']).to eq(organization.title.to_a)
          end
        end
      end
    end
  end
end
