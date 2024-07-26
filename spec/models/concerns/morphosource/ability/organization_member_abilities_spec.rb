# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)                  { FactoryBot.create(:contributor) }
  let(:ability)               { Ability.new(user) }
  let(:sending_user)          { FactoryBot.create(:contributor) }
  let(:proxy_deposit_request) { ProxyDepositRequest.new(receiving_user_id: organization.id, sending_user_id: sending_user.id, work_id: media.id, status: 'pending' ) }
  let(:depositor)             { FactoryBot.create(:contributor) }
  let(:organization)          { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }

  let(:org_manager)           { FactoryBot.create(:contributor) }
  let(:org_editor)            { FactoryBot.create(:contributor) }
  let(:org_depositor)         { FactoryBot.create(:contributor) }
  let(:org_downloader)        { FactoryBot.create(:registered_user) }
  let(:org_viewer)            { FactoryBot.create(:registered_user) }

  let(:org_members)           { [org_manager, org_editor, org_depositor, org_downloader, org_viewer] }
  let(:org_read_members)      { [org_manager, org_editor, org_downloader, org_viewer] }

  let(:file_set)               { FactoryBot.create(:file_set_document) }
  let(:media)                 { FactoryBot.create(:media_document, 
                                  file_set_ids_ssim: [file_set.id], 
                                  member_ids_ssim: [file_set.id],
                                  media_organization_id_ssim: [organization.id],
                              )}
  
  describe 'organization_member_abilities' do
    context 'the work does not exist' do
      let(:nonexistent_id) { '123' }

      it 'returns error or false' do
        expect{ability.can? :read, nonexistent_id }.to raise_error(Blacklight::Exceptions::RecordNotFound)
        expect(ability.can? :read, nil).to be(false)
      end
    end

    context 'with media that is private and is associated with org through object' do
      context 'the user is not a member of the media object organization' do
        before do
          allow(user).to receive(:groups).and_return([])
        end

        it 'returns false for read, edit, transfer, accept, and reject' do
          # media
          expect(can_read?(media)).to be(false)
          expect(can_edit?(media)).to be(false)
          expect(can_transfer?(media)).to be(false)
          expect(can_accept?(proxy_deposit_request)).to be(false)
          expect(can_reject?(proxy_deposit_request)).to be(false)

          # file set
          expect(can_read?(file_set)).to be(false)
          expect(can_edit?(file_set)).to be(false)
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
            # all non-depositor organization members can read org media and file sets
            it 'managers, editors, downloaders, and viewers can read but not edit the media' do
              org_read_members.each do |org_member|
                expect(can_read?(media, org_member)).to be(true)
                expect(can_edit?(media, org_member)).to be(false)
                expect(can_transfer?(media, org_member)).to be(false)
                expect(can_read?(file_set, org_member)).to be(true)
                expect(can_edit?(file_set, org_member)).to be(false)
              end
            end

            # depositor organization members can not read org media and file sets
            it 'depositors can not read or edit the media' do
              expect(can_read?(media, org_depositor)).to be(false)
              expect(can_edit?(media, org_depositor)).to be(false)
              expect(can_transfer?(media, org_depositor)).to be(false)
              expect(can_read?(file_set, org_depositor)).to be(false)
              expect(can_edit?(file_set, org_depositor)).to be(false)
            end
          end

          context 'the organization is the data owner' do
            let(:media) { FactoryBot.create(:media_document, 
                          file_set_ids_ssim: [file_set.id], 
                          member_ids_ssim: [file_set.id],
                          media_organization_id_ssim: [organization.id],
                          owner_ssim: [organization.id],
                          owner_type_ssi: 'OrganizationCollection'
                        )}

            it 'returns the correct permissions for manager member' do
              # manager can read, edit, transfer, accept, reject
              expect(can_read?(media, org_manager)).to be(true)
              expect(can_edit?(media, org_manager)).to be(true)
              expect(can_transfer?(media, org_manager)).to be(true)
              expect(can_accept?(proxy_deposit_request, org_manager)).to be(true)
              expect(can_reject?(proxy_deposit_request, org_manager)).to be(true)
              expect(can_read?(file_set, org_manager)).to be(true)
              expect(can_edit?(file_set, org_manager)).to be(true)
            end

            it 'returns the correct permissions for editor member' do
              # editor can read & edit, cannot transfer, accept, reject
              expect(can_read?(media, org_editor)).to be(true)
              expect(can_edit?(media, org_editor)).to be(true)
              expect(can_transfer?(media, org_editor)).to be(false)
              expect(can_accept?(proxy_deposit_request, org_editor)).to be(false)
              expect(can_reject?(proxy_deposit_request, org_editor)).to be(false)
              expect(can_read?(file_set, org_editor)).to be(true)
              expect(can_edit?(file_set, org_editor)).to be(true)
            end

            it 'returns the correct permissions for depositor member' do
              # depositor can't do anything
              expect(can_read?(media, org_depositor)).to be(false)
              expect(can_edit?(media, org_depositor)).to be(false)
              expect(can_transfer?(media, org_depositor)).to be(false)
              expect(can_accept?(proxy_deposit_request, org_depositor)).to be(false)
              expect(can_reject?(proxy_deposit_request, org_depositor)).to be(false)
              expect(can_read?(file_set, org_depositor)).to be(false)
              expect(can_edit?(file_set, org_depositor)).to be(false)
            end

            it 'returns the correct permissions for downloader' do
              # downloader, and viewer can read, cannot edit, transfer, accept, reject
              expect(can_read?(media, org_downloader)).to be(true)
              expect(can_edit?(media, org_downloader)).to be(false)
              expect(can_transfer?(media, org_downloader)).to be(false)
              expect(can_accept?(proxy_deposit_request, org_downloader)).to be(false)
              expect(can_reject?(proxy_deposit_request, org_downloader)).to be(false)
              expect(can_read?(file_set, org_downloader)).to be(true)
              expect(can_edit?(file_set, org_downloader)).to be(false)
            end

            it 'returns the correct permissions for viewer' do
              # downloader, and viewer can read, cannot edit, transfer, accept, reject
              expect(can_read?(media, org_viewer)).to be(true)
              expect(can_edit?(media, org_viewer)).to be(false)
              expect(can_transfer?(media, org_viewer)).to be(false)
              expect(can_accept?(proxy_deposit_request, org_viewer)).to be(false)
              expect(can_reject?(proxy_deposit_request, org_viewer)).to be(false)
              expect(can_read?(file_set, org_viewer)).to be(true)
              expect(can_edit?(file_set, org_viewer)).to be(false)
            end

            context 'edge case - the media is owned by the organization but is not otherwise associated with the organization' do
              let(:media) { FactoryBot.create(:media_document, 
                          file_set_ids_ssim: [file_set.id], 
                          member_ids_ssim: [file_set.id],
                          media_organization_id_ssim: ["123456789"],
                          owner_ssim: [organization.id],
                          owner_type_ssi: 'OrganizationCollection'
                        )}
              
              it 'returns the correct permissions for manager member' do
                # manager can read, edit, transfer, accept, reject
                expect(can_read?(media, org_manager)).to be(true)
                expect(can_edit?(media, org_manager)).to be(true)
                expect(can_transfer?(media, org_manager)).to be(true)
                expect(can_accept?(proxy_deposit_request, org_manager)).to be(true)
                expect(can_reject?(proxy_deposit_request, org_manager)).to be(true)
                expect(can_read?(file_set, org_manager)).to be(true)
                expect(can_edit?(file_set, org_manager)).to be(true)
              end
  
              it 'returns the correct permissions for editor member' do
                # editor can read & edit, cannot transfer, accept, reject
                expect(can_read?(media, org_editor)).to be(true)
                expect(can_edit?(media, org_editor)).to be(true)
                expect(can_transfer?(media, org_editor)).to be(false)
                expect(can_accept?(proxy_deposit_request, org_editor)).to be(false)
                expect(can_reject?(proxy_deposit_request, org_editor)).to be(false)
                expect(can_read?(file_set, org_editor)).to be(true)
                expect(can_edit?(file_set, org_editor)).to be(true)
              end
  
              it 'returns the correct permissions for depositor member' do
                # depositor can't do anything
                expect(can_read?(media, org_depositor)).to be(false)
                expect(can_edit?(media, org_depositor)).to be(false)
                expect(can_transfer?(media, org_depositor)).to be(false)
                expect(can_accept?(proxy_deposit_request, org_depositor)).to be(false)
                expect(can_reject?(proxy_deposit_request, org_depositor)).to be(false)
                expect(can_read?(file_set, org_depositor)).to be(false)
                expect(can_edit?(file_set, org_depositor)).to be(false)
              end
  
              it 'returns the correct permissions for downloader' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(media, org_downloader)).to be(true)
                expect(can_edit?(media, org_downloader)).to be(false)
                expect(can_transfer?(media, org_downloader)).to be(false)
                expect(can_accept?(proxy_deposit_request, org_downloader)).to be(false)
                expect(can_reject?(proxy_deposit_request, org_downloader)).to be(false)
                expect(can_read?(file_set, org_downloader)).to be(true)
                expect(can_edit?(file_set, org_downloader)).to be(false)
              end
  
              it 'returns the correct permissions for viewer' do
                # downloader, and viewer can read, cannot edit, transfer, accept, reject
                expect(can_read?(media, org_viewer)).to be(true)
                expect(can_edit?(media, org_viewer)).to be(false)
                expect(can_transfer?(media, org_viewer)).to be(false)
                expect(can_accept?(proxy_deposit_request, org_viewer)).to be(false)
                expect(can_reject?(proxy_deposit_request, org_viewer)).to be(false)
                expect(can_read?(file_set, org_viewer)).to be(true)
                expect(can_edit?(file_set, org_viewer)).to be(false)
              end
            end
          end
        end

        context 'the organization is a work' do
          let(:organizational_team) { FactoryBot.create(:team, depositor: depositor.ms_id) }
          let(:organization)        { FactoryBot.create(:organization, team_id: [organizational_team.id]) }

          before do
            organizational_team.create_collection_groups
            organizational_team.viewers << user
            organizational_team.viewers_group.save!
          end

          it 'returns false for media and file sets' do
            # media
            expect(can_read?(media)).to be(false)
            # file set
            expect(can_read?(file_set)).to be(false)
          end
        end
      end
    end

    # This was added due to a very specific bug noticed affecting subsequent ability reads for different media
    context 'with multiple media works, both associated with org, one org managed and one not' do
      let(:org_media_unmanaged) { 
        FactoryBot.create(:media_document, 
          file_set_ids_ssim: [file_set.id], 
          member_ids_ssim: [file_set.id],
          media_organization_id_ssim: [organization.id],
        )
      }

      # change ID to prevent collision with other file set
      let(:file_set_managed) { FactoryBot.create(:file_set_document, id: "987654329") }
      let(:org_media_managed) { 
        FactoryBot.create(:media_document, 
          file_set_ids_ssim: [file_set_managed.id], 
          member_ids_ssim: [file_set_managed.id],
          media_organization_id_ssim: [organization.id],
          owner_ssim: [organization.id],
          owner_type_ssi: 'OrganizationCollection'
        )
      }

      before do
        # add organization users to groups
        organization.managers << org_manager
        organization.editors << org_editor
        organization.depositors << org_depositor
        organization.downloaders << org_downloader
        organization.viewers << org_viewer
        organization.user_groups.each(&:save)
      end

      it 'returns the correct permissions for manager member for both media' do
        # manager can read, edit, transfer, accept, reject managed media
        expect(can_read?(org_media_managed, org_manager)).to be(true)
        expect(can_edit?(org_media_managed, org_manager)).to be(true)
        expect(can_transfer?(org_media_managed, org_manager)).to be(true)
        expect(can_read?(file_set_managed, org_manager)).to be(true)
        expect(can_edit?(file_set_managed, org_manager)).to be(true)

        # manager can read, but not edit, transfer, accept, reject unmanaged media
        expect(can_read?(org_media_unmanaged, org_manager)).to be(true)
        expect(can_edit?(org_media_unmanaged, org_manager)).to be(false)
        expect(can_transfer?(org_media_unmanaged, org_manager)).to be(false)
        expect(can_read?(file_set, org_manager)).to be(true)
        expect(can_edit?(file_set, org_manager)).to be(false)

        # check managed media again to ensure things are working regardless of order
        expect(can_read?(org_media_managed, org_manager)).to be(true)
        expect(can_edit?(org_media_managed, org_manager)).to be(true)
        expect(can_transfer?(org_media_managed, org_manager)).to be(true)
        expect(can_read?(file_set_managed, org_manager)).to be(true)
        expect(can_edit?(file_set_managed, org_manager)).to be(true)
      end 
    end

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
