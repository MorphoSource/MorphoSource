# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)              { FactoryBot.create(:contributor) }
  let(:ability)           { Ability.new(user) }

  let(:depositor)         { FactoryBot.create(:contributor) }
  let(:organization)      { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

  let(:org_manager)       { FactoryBot.create(:contributor) }
  let(:org_editor)        { FactoryBot.create(:contributor) }
  let(:org_depositor)     { FactoryBot.create(:contributor) }
  let(:org_downloader)    { FactoryBot.create(:registered_user) }
  let(:org_viewer)        { FactoryBot.create(:registered_user) }

  let(:org_members)       { [org_manager, org_editor, org_depositor, org_downloader, org_viewer] }
  let(:org_read_members)  { [org_manager, org_editor, org_downloader, org_viewer] }

  describe 'PhysicalObjectAbilities' do
    context 'with physical objects associated with org' do
      context 'object is private biological specimen (fake, normally all objects are public)' do
        let(:biological_specimen)   { FactoryBot.create(:biological_specimen_document,
                                        organization_id_tesim: [organization.id]
                                    )}

        context 'the user is not a member of the object organization' do
          before do
            allow(user).to receive(:groups).and_return([])
          end

          it 'returns false for read and edit' do
            expect(can_read?(biological_specimen)).to be(false)
            expect(can_edit?(biological_specimen)).to be(false)
          end
        end

        context 'the user is a member of the media organization' do
          context 'the organization is a collection' do
            before do
              # add organization users to groups
              organization.managers << org_manager
              organization.editors << org_editor
              organization.depositors << org_depositor
              organization.downloaders << org_downloader
              organization.viewers << org_viewer
              organization.user_groups.each(&:save)
            end

            context 'the organization is not the data owner' do
              it 'returns the correct permissions for manager member' do
                # manager can read, edit
                expect(can_read?(biological_specimen, org_manager)).to be(true)
                expect(can_edit?(biological_specimen, org_manager)).to be(true)

              end

              it 'returns the correct permissions for editor member' do
                # editor can read & edit
                expect(can_read?(biological_specimen, org_editor)).to be(true)
                expect(can_edit?(biological_specimen, org_editor)).to be(true)

              end

              it 'depositors can not read or edit the object' do
                expect(can_read?(biological_specimen, org_depositor)).to be(false)
                expect(can_edit?(biological_specimen, org_depositor)).to be(false)
              end

              it 'returns the correct permissions for downloader' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(biological_specimen, org_downloader)).to be(true)
                expect(can_edit?(biological_specimen, org_downloader)).to be(false)

              end

              it 'returns the correct permissions for viewer' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(biological_specimen, org_viewer)).to be(true)
                expect(can_edit?(biological_specimen, org_viewer)).to be(false)
              end
            end
          end
        end
      end

      context 'object is private cultural heritage object (fake, normally all objects are public)' do
        let(:cho)   { FactoryBot.create(:cultural_heritage_object_document,
                        organization_id_tesim: [organization.id]
                    )}

        context 'the user is not a member of the object organization' do
          before do
            allow(user).to receive(:groups).and_return([])
          end

          it 'returns false for read and edit' do
            expect(can_read?(cho)).to be(false)
            expect(can_edit?(cho)).to be(false)
          end
        end

        context 'the user is a member of the media organization' do
          context 'the organization is a collection' do
            before do
              # add organization users to groups
              organization.managers << org_manager
              organization.editors << org_editor
              organization.depositors << org_depositor
              organization.downloaders << org_downloader
              organization.viewers << org_viewer
              organization.user_groups.each(&:save)
            end

            context 'the organization is not the data owner' do
              it 'returns the correct permissions for manager member' do
                # manager can read, edit
                expect(can_read?(cho, org_manager)).to be(true)
                expect(can_edit?(cho, org_manager)).to be(true)

              end

              it 'returns the correct permissions for editor member' do
                # editor can read & edit
                expect(can_read?(cho, org_editor)).to be(true)
                expect(can_edit?(cho, org_editor)).to be(true)

              end

              it 'depositors can not read or edit the object' do
                expect(can_read?(cho, org_depositor)).to be(false)
                expect(can_edit?(cho, org_depositor)).to be(false)
              end

              it 'returns the correct permissions for downloader' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(cho, org_downloader)).to be(true)
                expect(can_edit?(cho, org_downloader)).to be(false)

              end

              it 'returns the correct permissions for viewer' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(cho, org_viewer)).to be(true)
                expect(can_edit?(cho, org_viewer)).to be(false)
              end
            end
          end
        end
      end
    end
  end
end
