require 'rails_helper'
RSpec.describe Morphosource::OrganizationNormalizationJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  subject { described_class.new }

  let(:user)                  { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)             { User.create(email: 'depositor@email.com', password: 'password') }
  let(:manager)               { User.create(email: 'manager@email.com', password: 'password') }

  let!(:media)                { Media.create(title: ['Media'],
                                             depositor: depositor.ms_id,
                                             fileset_accessibility: ["private"],
                                             agreement_uri: ["media agreement uri"],
                                             morphosource_use_agreement_type: ["Restrictive"],
                                             required_archival_of_published_derivatives: ["Nowhere"],
                                             permits_commercial_use: ["CommercialUsePermitted"],
                                             permits_3d_use: ["3DPrintingNotPermitted"],
                                             rights_holder: ["Media Rights Holder"],
                                             preview_mode: ["Thumbnail Only"],
                                             license: ["media original license"],
                                             rights_statement: ["media original rights statement"],
                                             publisher: ["media publisher"]) }



  before do
    subject.instance_variable_set(:@media, media)
    subject.instance_variable_set(:@organization, organization)
    subject.instance_variable_set(:@user, user)
    subject.instance_variable_set(:@remove_previous_reviewers, false)
    allow(SolrDocument).to receive(:find).with(media.id).and_return(SolrDocument.find(media.id))
  end

  describe 'perform' do
    context 'organization is a work' do
      let(:organization)  { FactoryBot.create(:organization) }
      it 'calls the correct normalization method' do
        expect_any_instance_of(described_class).to receive(:normalize_team_media)
        described_class.perform_now(media_id: media.id, organization_id: organization.id, remove_previous_reviewers: 'true', user_email: user.email, update_publication_status: 'all')
      end
    end
    context 'organization is a collection' do
      let(:organization)  { FactoryBot.create(:organization_collection) }
      it 'calls the correct normalization method' do
        expect_any_instance_of(described_class).to receive(:normalize_organization_media)
        described_class.perform_now(media_id: media.id, organization_id: organization.id, remove_previous_reviewers: 'true', user_email: nil, update_publication_status: 'all')
      end
      context 'the argments are valid' do
        let(:args)  { {media_id: media.id, organization_id: organization.id, remove_previous_reviewers: 'true', user_email: nil, update_publication_status: 'all'} }
        it 'returns true' do
          expect(described_class.perform_now(**args)).to be true
        end
      end
      context 'the arguments are invalid' do
        let(:args)  { {media_id: media.id, organization_id: organization.id, remove_previous_reviewers: nil, user_email: nil, update_publication_status: 'all'} }
        it 'returns false' do
          expect(described_class.perform_now(**args)).to be false
        end
      end
    end
  end

  context 'organization is a work' do
    let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:organization)          { Organization.create(title: ['Organization'],
                                                    team_id: [team.id],
                                                    download_reviewer: [manager.ms_id],
                                                    download_permission: ["open"],
                                                    agreement_uri: ["agreement uri"],
                                                    morphosource_use_agreement_type: ["Standard"],
                                                    required_archival_of_published_derivatives: ["OnMorphoSource"],
                                                    permits_commercial_use: ["CommercialUseNotPermitted"],
                                                    permits_3d_use: ["3DPrintingPermitted"],
                                                    rights_holder: ["Rights Holder"],
                                                    preview_mode: ["Interactive/Embeddable"],
                                                    license: ["https://creativecommons.org/licenses/by-nc/4.0/"],
                                                    rights_statement: ["http://rightsstatements.org/vocab/UND/1.0/"],
                                                    publisher: ["Publisher"]) }


    before do
      subject.instance_variable_set(:@team, team)
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
    end

    describe 'reviewer preservation for deprecated teams' do
      ["open", "restricted_download", "private"].each do |status|
        ["true", "false"].each do |remove|
          it "keeps record reviewers for #{status}, remove_previous_reviewers=#{remove}" do
            media.record_download_reviewer_users = [user.ms_id]
            media.fileset_accessibility = [status]
            media.visibility = status == 'private' ? 'restricted' : 'open'
            media.save!
            expect(subject).not_to receive(:update_download_reviewer)
            subject.normalize_team_media(media.id, user.email, remove, 'none')
            expect(media.reload.record_download_reviewer_users).to eq([user.ms_id])
          end
        end
      end
    end

    describe 'update_media_publication_status' do

      context 'update_publication_status is none' do
        before do
          subject.instance_variable_set(:@update_publication_status, 'none')
        end

        context 'media is open' do
          before do
            media_is_open_download
          end

          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.open?).to be(true)
          end
        end

        context 'media is restricted download' do
          before do
            media_is_restricted_download
          end
          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.restricted_download?).to be(true)
          end
        end

        context 'media is private' do
          before do
            media_is_private
          end

          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.private?).to be(true)
          end
        end
      end

      context 'update_publication_status is all' do

        before do
          subject.instance_variable_set(:@update_publication_status, 'all')
        end

        context 'organization publication status is open' do
          before do
            organization.download_permission = ['open']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'does not change the status' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end
        end

        context 'oprganization publication status is restricted download' do
          before do
            organization.download_permission = ['restricted_download']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'changes it to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end
        end

        context 'organization publication status is private' do
          before do
            organization.download_permission = ['restricted']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes the media to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end
      end

      context 'update_publication_status is published' do

        before do
          subject.instance_variable_set(:@update_publication_status, 'published')
        end

        context 'organization publication status is open' do
          before do
            organization.download_permission = ['open']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'does not change the status' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end

        context 'organization publication status is restricted download' do
          before do
            organization.download_permission = ['restricted_download']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end

        context 'organization publication status is private' do
          before do
            organization.download_permission = ['restricted']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end
      end
    end

    describe 'update_data_manager' do

      it 'updates the data manager' do
        subject.send(:update_data_manager)
        expect(media.owner).to eq(user.ms_id)
        expect(media.edit_users).to include(user.ms_id)
      end
    end

    describe 'update_permissions' do
      context 'all organization permissions have values' do
        let(:file_path)             { fixture_path + '/text/text.txt' }
        let(:uploaded_file)         { Rack::Test::UploadedFile.new(file_path) }

        before do
          organization.agreement_attachment = uploaded_file
        end

        it 'copies the organization permissions' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(organization.morphosource_use_agreement_type)
          expect(media.required_archival_of_published_derivatives).to match_array(organization.required_archival_of_published_derivatives)
          expect(media.permits_commercial_use).to match_array(organization.permits_commercial_use)
          expect(media.permits_3d_use).to match_array(organization.permits_3d_use)
          expect(media.rights_holder).to match_array(organization.rights_holder)
          expect(media.preview_mode).to match_array(organization.preview_mode)
          expect(media.license).to match_array(organization.license)
          expect(media.rights_statement).to match_array(organization.rights_statement)
          expect(media.agreement_attachment_url).to include("text.txt")
        end
      end
      context 'all organization permissions are no preference' do
        before do
          media.preview_mode = ["Thumbnail Only"]
          media.save!

          organization.update(download_reviewer: [],
          download_permission: [],
          agreement_uri: [],
          morphosource_use_agreement_type: [],
          required_archival_of_published_derivatives: [],
          permits_commercial_use: [],
          permits_3d_use: [],
          rights_holder: [],
          preview_mode: [],
          license: [],
          rights_statement: [],
          publisher: [],
          rights_statement_blank: [],
          license_blank: [],
          rights_holder_blank: [])

          organization.agreement_attachment = nil
        end

        it 'does not change the media permissions' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(["Restrictive"])
          expect(media.required_archival_of_published_derivatives).to match_array(["Nowhere"])
          expect(media.permits_commercial_use).to match_array(["CommercialUsePermitted"])
          expect(media.permits_3d_use).to match_array(["3DPrintingNotPermitted"])
          expect(media.rights_holder).to match_array(["Media Rights Holder"])
          expect(media.preview_mode).to match_array(["Thumbnail Only"])
          expect(media.license).to match_array(["media original license"])
          expect(media.rights_statement).to match_array(["media original rights statement"])
          expect(media.fileset_accessibility).to match_array(["private"])
          expect(media.agreement_uri).to match_array(["media agreement uri"])
        end
      end

      context 'all organization permissions are blank, rights statement, license, and rights holder are intentionally blank' do
        before do
          media.preview_mode = ["Thumbnail Only"]
          media.save!

          organization.update(download_reviewer: [],
          download_permission: [],
          agreement_uri: [],
          morphosource_use_agreement_type: [],
          required_archival_of_published_derivatives: [],
          permits_commercial_use: [],
          permits_3d_use: [],
          rights_holder: [],
          preview_mode: [],
          license: [],
          rights_statement: [],
          publisher: [],
          rights_statement_blank: ["1"],
          license_blank: ["1"],
          rights_holder_blank: ["1"])

          organization.agreement_attachment = nil
        end

        it 'does not change the media permissions except for license, rights_statement, and rights_holder' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(["Restrictive"])
          expect(media.required_archival_of_published_derivatives).to match_array(["Nowhere"])
          expect(media.permits_commercial_use).to match_array(["CommercialUsePermitted"])
          expect(media.permits_3d_use).to match_array(["3DPrintingNotPermitted"])
          expect(media.preview_mode).to match_array(["Thumbnail Only"])
          expect(media.fileset_accessibility).to match_array(["private"])
          expect(media.agreement_uri).to match_array(["media agreement uri"])
          expect(media.license).to match_array([])
          expect(media.rights_statement).to match_array([])
          expect(media.rights_holder).to match_array([])
        end
      end
    end

    describe 'add_media_to_team' do
      it 'adds all media to the team' do
        subject.send(:add_media_to_team)
        media.reload
        expect(media.member_of_collections).to include(team)
      end
    end
  end

  context 'organization is a collection' do
    let!(:organization)  { FactoryBot.create(:organization_collection,
                                             title: ['Organization'],
                                             download_permission: ["open"],
                                             download_reviewer: [manager.ms_id],
                                             agreement_uri: ["agreement uri"],
                                             morphosource_use_agreement_type: ["Standard"],
                                             required_archival_of_published_derivatives: ["OnMorphoSource"],
                                             permits_commercial_use: ["CommercialUseNotPermitted"],
                                             permits_3d_use: ["3DPrintingPermitted"],
                                             rights_holder: ["Rights Holder"],
                                             preview_mode: ["Interactive/Embeddable"],
                                             license: ["https://creativecommons.org/licenses/by-nc/4.0/"],
                                             rights_statement: ["http://rightsstatements.org/vocab/UND/1.0/"],
                                             publisher: ["Publisher"]) }

    describe 'update_download_reviewer' do
      before do
        organization.managers_group.users << manager
        organization.update_index
        media.record_download_reviewer_users = [user.ms_id]
      end

      ["open", "restricted_download", "private"].each do |status|
        ["true", "false"].each do |remove|
          it "resolves reviewers for #{status}, remove_previous_reviewers=#{remove}" do
            media.fileset_accessibility = [status]
            media.visibility = status == 'private' ? 'restricted' : 'open'
            subject.instance_variable_set(:@remove_previous_reviewers, remove)
            subject.update_download_reviewer
            subject.update_data_manager
            media.save!
            expected = status == 'open' || remove == 'true' ? [] : [user.ms_id]
            expect(media.record_download_reviewer_users).to eq(expected)
            expect(media.download_reviewer_mode).to eq('record_users')
            expect(Morphosource::DownloadReviewerResolver.new.call(media)).to eq(expected.presence || [manager.ms_id])
          end
        end
      end
    end

    describe 'update_media_publication_status' do

      context 'update_publication_status is none' do
        before do
          subject.instance_variable_set(:@update_publication_status, 'none')
        end

        context 'media is open' do
          before do
            media_is_open_download
          end

          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.open?).to be(true)
          end
        end

        context 'media is restricted download' do
          before do
            media_is_restricted_download
          end
          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.restricted_download?).to be(true)
          end
        end

        context 'media is private' do
          before do
            media_is_private
          end

          it 'does not change the media publication status' do
            subject.send(:update_media_publication_status)
            expect(media.private?).to be(true)
          end
        end
      end

      context 'update_publication_status is all' do

        before do
          subject.instance_variable_set(:@update_publication_status, 'all')
        end

        context 'organization publication status is open' do
          before do
            organization.download_permission = ['open']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'does not change the status' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end
        end

        context 'oprganization publication status is restricted download' do
          before do
            organization.download_permission = ['restricted_download']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'changes it to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end
        end

        context 'organization publication status is private' do
          before do
            organization.download_permission = ['restricted']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes the media to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end
      end

      context 'update_publication_status is published' do

        before do
          subject.instance_variable_set(:@update_publication_status, 'published')
        end

        context 'organization publication status is open' do
          before do
            organization.download_permission = ['open']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'does not change the status' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to open' do
              subject.send(:update_media_publication_status)
              expect(media.open?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end

        context 'organization publication status is restricted download' do
          before do
            organization.download_permission = ['restricted_download']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to restricted download' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.restricted_download?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end

        context 'organization publication status is private' do
          before do
            organization.download_permission = ['restricted']
            organization.save!
          end

          context 'media is open' do
            before do
              media_is_open_download
            end
            it 'changes to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is restricted download' do
            before do
              media_is_restricted_download
            end
            it 'changes it to private' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end

          context 'media is private' do
            before do
              media_is_private
            end
            it 'does not change' do
              subject.send(:update_media_publication_status)
              expect(media.private?).to be(true)
            end
          end
        end
      end
    end

    describe 'update_data_manager' do
      it 'updates the data manager' do
        subject.send(:update_data_manager)
        expect(media.owner).to eq(organization.id)
      end
    end

    describe 'update_permissions' do
      context 'all organization permissions have values' do
        let(:file_path)             { fixture_path + '/text/text.txt' }
        let(:uploaded_file)         { Rack::Test::UploadedFile.new(file_path) }

        before do
          organization.agreement_attachment = uploaded_file
        end

        it 'copies the organization permissions' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(organization.morphosource_use_agreement_type)
          expect(media.required_archival_of_published_derivatives).to match_array(organization.required_archival_of_published_derivatives)
          expect(media.permits_commercial_use).to match_array(organization.permits_commercial_use)
          expect(media.permits_3d_use).to match_array(organization.permits_3d_use)
          expect(media.rights_holder).to match_array(organization.rights_holder)
          expect(media.preview_mode).to match_array(organization.preview_mode)
          expect(media.license).to match_array(organization.license)
          expect(media.rights_statement).to match_array(organization.rights_statement)
          expect(media.agreement_attachment_url).to include("text.txt")
        end
      end
      context 'all organization permissions are no preference' do
        before do
          media.preview_mode = ["Thumbnail Only"]
          media.save!
          organization.update(download_reviewer: [],
          download_permission: [],
          agreement_uri: [],
          morphosource_use_agreement_type: [],
          required_archival_of_published_derivatives: [],
          permits_commercial_use: [],
          permits_3d_use: [],
          rights_holder: [],
          preview_mode: [],
          license: [],
          rights_statement: [],
          publisher: [],
          rights_statement_blank: [],
          license_blank: [],
          rights_holder_blank: [])

          organization.agreement_attachment = nil
        end

        it 'does not change the media permissions' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(["Restrictive"])
          expect(media.required_archival_of_published_derivatives).to match_array(["Nowhere"])
          expect(media.permits_commercial_use).to match_array(["CommercialUsePermitted"])
          expect(media.permits_3d_use).to match_array(["3DPrintingNotPermitted"])
          expect(media.rights_holder).to match_array(["Media Rights Holder"])
          expect(media.preview_mode).to match_array(["Thumbnail Only"])
          expect(media.license).to match_array(["media original license"])
          expect(media.rights_statement).to match_array(["media original rights statement"])
          expect(media.fileset_accessibility).to match_array(["private"])
          expect(media.agreement_uri).to match_array(["media agreement uri"])
        end
      end

      context 'all organization permissions are blank, rights statement, license, and rights holder are intentionally blank' do
        before do
          media.preview_mode = ["Thumbnail Only"]
          media.save!

          organization.update(download_reviewer: [],
          download_permission: [],
          agreement_uri: [],
          morphosource_use_agreement_type: [],
          required_archival_of_published_derivatives: [],
          permits_commercial_use: [],
          permits_3d_use: [],
          rights_holder: [],
          preview_mode: [],
          license: [],
          rights_statement: [],
          publisher: [],
          rights_statement_blank: ["1"],
          license_blank: ["1"],
          rights_holder_blank: ["1"])

          organization.agreement_attachment = nil
        end

        it 'does not change the media permissions except for license, rights_statement, and rights_holder' do
          subject.send(:update_permissions)
          expect(media.morphosource_use_agreement_type).to match_array(["Restrictive"])
          expect(media.required_archival_of_published_derivatives).to match_array(["Nowhere"])
          expect(media.permits_commercial_use).to match_array(["CommercialUsePermitted"])
          expect(media.permits_3d_use).to match_array(["3DPrintingNotPermitted"])
          expect(media.preview_mode).to match_array(["Thumbnail Only"])
          expect(media.fileset_accessibility).to match_array(["private"])
          expect(media.agreement_uri).to match_array(["media agreement uri"])
          expect(media.license).to match_array([])
          expect(media.rights_statement).to match_array([])
          expect(media.rights_holder).to match_array([])
        end
      end
    end
  end

  # helper methods

  def media_is_open_download
    media.visibility = 'open'
    media.fileset_accessibility = ['open']
    media.save!
    media.reload
  end

  def media_is_restricted_download
    media.visibility = 'open'
    media.fileset_accessibility = ['restricted_download']
    media.save!
    media.reload
  end

  def media_is_private
    media.visibility = 'restricted'
    media.fileset_accessibility = ['private']
    media.save!
    media.reload
  end
end
