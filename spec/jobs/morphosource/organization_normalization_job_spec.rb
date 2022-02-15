require 'rails_helper'
RSpec.describe Morphosource::OrganizationNormalizationJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  subject { described_class.new }

  let(:user)                  { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)             { User.create(email: 'depositor@email.com', password: 'password') }
  let(:manager)               { User.create(email: 'manager@email.com', password: 'password') }
  let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:media)                 { Media.create(title: ['Media'], depositor: depositor.ms_id) }
  let(:organization)          { Organization.create(
                                  title: ['Organization'],
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
    Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)

    subject.instance_variable_set(:@media, media)
    subject.instance_variable_set(:@organization, organization)
    subject.instance_variable_set(:@user, user)
    subject.instance_variable_set(:@team, team)
  end

  describe 'perform' do
    it 'calls normalization methods' do
      expect_any_instance_of(described_class).to receive(:update_download_reviewer)
      expect_any_instance_of(described_class).to receive(:update_media_publication_status)
      expect_any_instance_of(described_class).to receive(:update_data_manager)
      expect_any_instance_of(described_class).to receive(:update_permissions)
      expect_any_instance_of(described_class).to receive(:add_media_to_team)
      described_class.perform_now(media_id: media.id, organization_id: organization.id, user_email: user.email, update_publication_status: 'all')
    end
  end

  describe 'update_download_reviewer' do

    context 'media is open' do
      before do
        media_is_open_download
      end
      it 'updates the download reviewer to the organization download reviewer' do
        subject.send(:update_download_reviewer)
        expect(media.download_reviewer).to match_array(organization.download_reviewer)
      end
    end

    context 'media is restricted' do
      before do
        media_is_restricted_download
      end
      it 'updates the download reviewer to the media reviewer + organization download reviewer' do
        subject.send(:update_download_reviewer)
        expect(media.download_reviewer).to match_array([depositor.ms_id] + organization.download_reviewer.to_a)
      end
    end

    context 'media is private' do
      before do
        media.download_reviewer = [user.ms_id]
        media_is_private
      end
      it 'updates the download reviewer to the media download reviewer + organization download reviewer' do
        subject.send(:update_download_reviewer)
        expect(media.download_reviewer).to match_array([user.ms_id] + organization.download_reviewer.to_a)
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
    let(:file_path)             { fixture_path + '/text/text.txt' }
    let(:uploaded_file)         { Rack::Test::UploadedFile.new(file_path) }

    before do
      Morphosource::AttachmentService.create(organization, 'agreement', uploaded_file)
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
      expect(media.attachment('agreement')).to include("agreement.txt")
    end
  end

  describe 'add_media_to_team' do
    it 'adds all media to the team' do
      subject.send(:add_media_to_team)
      media.reload
      expect(media.member_of_collections).to include(team)
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
