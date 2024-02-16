# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)            { FactoryBot.create(:registered_user) }
  let(:ability)         { Ability.new(user) }

  let(:media)           { FactoryBot.create(:media) }
  let(:media_doc)       { SolrDocument.find(media.id) }

  let(:file_set)        { FactoryBot.create(:file_set) }
  let(:file_set_doc)    { SolrDocument.new(file_set.to_solr) }

  before do
    media.ordered_members << file_set
    media.save!
  end

  describe 'organizational_member_abilities' do
    context 'the work does not exist' do
      let(:nonexistent_id) { '123' }

      it 'returns false' do
        expect(ability.can? :read, nonexistent_id).to be(false)
        expect(ability.can? :read, nil).to be(false)
      end
    end

    context 'the work is private' do
      context 'the user is not a member of the media organization' do
        before do
          allow(user).to receive(:groups).and_return([])
        end

        it 'returns false for media and file sets' do
          # media
          expect(ability.can? :read, media.id).to be(false)
          expect(ability.can? :read, media).to be(false)
          expect(ability.can? :read, media_doc).to be(false)
          expect(user.can? :read, media.id).to be(false)
          expect(user.can? :read, media).to be(false)
          expect(user.can? :read, media_doc).to be(false)
          # file set
          expect(ability.can? :read, file_set.id).to be(false)
          expect(ability.can? :read, file_set).to be(false)
          expect(ability.can? :read, file_set_doc).to be(false)
          expect(user.can? :read, file_set.id).to be(false)
          expect(user.can? :read, file_set).to be(false)
          expect(user.can? :read, file_set_doc).to be(false)
        end
      end

      context 'the user is a member of the media organization' do
        let(:depositor)     { FactoryBot.create(:contributor) }
        let(:specimen)      { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
        let(:device)        { FactoryBot.create(:device) }
        let(:imaging_event) { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id]) }

        before do
          imaging_event.ordered_members << media
          imaging_event.save!
          media.save!
        end

        context 'the organization is a collection' do
          let(:organization)  { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

          context 'the organization is not the data owner' do
            context 'the user has a manager or editor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_managers"])
              end

              it 'returns false for media and file sets' do
                # media
                expect(ability.can? :edit, media.id).to be(false)
                expect(ability.can? :edit, media).to be(false)
                expect(ability.can? :edit, media_doc).to be(false)
                expect(user.can? :edit, media.id).to be(false)
                expect(user.can? :edit, media).to be(false)
                expect(user.can? :edit, media_doc).to be(false)
                # file set
                expect(ability.can? :edit, file_set.id).to be(false)
                expect(ability.can? :edit, file_set).to be(false)
                expect(ability.can? :edit, file_set_doc).to be(false)
                expect(user.can? :edit, file_set.id).to be(false)
                expect(user.can? :edit, file_set).to be(false)
                expect(user.can? :edit, file_set_doc).to be(false)
              end
            end
            context 'the user has another role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_viewers"])
              end

              it 'returns false for media and file sets' do
                # media
                expect(ability.can? :edit, media.id).to be(false)
                expect(ability.can? :edit, media).to be(false)
                expect(ability.can? :edit, media_doc).to be(false)
                expect(user.can? :edit, media.id).to be(false)
                expect(user.can? :edit, media).to be(false)
                expect(user.can? :edit, media_doc).to be(false)
                # file set
                expect(ability.can? :edit, file_set.id).to be(false)
                expect(ability.can? :edit, file_set).to be(false)
                expect(ability.can? :edit, file_set_doc).to be(false)
                expect(user.can? :edit, file_set.id).to be(false)
                expect(user.can? :edit, file_set).to be(false)
                expect(user.can? :edit, file_set_doc).to be(false)
              end
            end
          end


          context 'the organization is the data owner' do
            before do
              media.owner = organization.id
              media.save!
            end
            context 'the user has a manager or editor role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_managers"])
              end

              it 'returns true for media and file sets' do
                # media
                expect(ability.can? :edit, media.id).to be(true)
                expect(ability.can? :edit, media).to be(true)
                expect(ability.can? :edit, media_doc).to be(true)
                expect(user.can? :edit, media.id).to be(true)
                expect(user.can? :edit, media).to be(true)
                expect(user.can? :edit, media_doc).to be(true)
                # file set
                expect(ability.can? :edit, file_set.id).to be(true)
                expect(ability.can? :edit, file_set).to be(true)
                expect(ability.can? :edit, file_set_doc).to be(true)
                expect(user.can? :edit, file_set.id).to be(true)
                expect(user.can? :edit, file_set).to be(true)
                expect(user.can? :edit, file_set_doc).to be(true)
              end
            end
            context 'the user has another role' do
              before do
                allow(user).to receive(:groups).and_return(["#{organization.id}_viewers"])
              end

              it 'returns false for media and file sets' do
                # media
                expect(ability.can? :edit, media.id).to be(false)
                expect(ability.can? :edit, media).to be(false)
                expect(ability.can? :edit, media_doc).to be(false)
                expect(user.can? :edit, media.id).to be(false)
                expect(user.can? :edit, media).to be(false)
                expect(user.can? :edit, media_doc).to be(false)
                # file set
                expect(ability.can? :edit, file_set.id).to be(false)
                expect(ability.can? :edit, file_set).to be(false)
                expect(ability.can? :edit, file_set_doc).to be(false)
                expect(user.can? :edit, file_set.id).to be(false)
                expect(user.can? :edit, file_set).to be(false)
                expect(user.can? :edit, file_set_doc).to be(false)
              end
            end
          end
        end

        context 'the organization is a work' do
          let(:organizational_team) { FactoryBot.create(:team) }
          let(:organization)        { FactoryBot.create(:organization, team_id: [organizational_team.id]) }

          before do
            allow(user).to receive(:groups).and_return(["#{organizational_team.id}_viewers"])
          end

          it 'returns true for media and file sets' do
            # media
            expect(ability.can? :read, media.id).to be(true)
            expect(ability.can? :read, media).to be(true)
            expect(ability.can? :read, media_doc).to be(true)
            expect(user.can? :read, media.id).to be(true)
            expect(user.can? :read, media).to be(true)
            expect(user.can? :read, media_doc).to be(true)
            # file set
            expect(ability.can? :read, file_set.id).to be(true)
            expect(ability.can? :read, file_set).to be(true)
            expect(ability.can? :read, file_set_doc).to be(true)
            expect(user.can? :read, file_set.id).to be(true)
            expect(user.can? :read, file_set).to be(true)
            expect(user.can? :read, file_set_doc).to be(true)
          end
        end
      end
    end
  end
end
