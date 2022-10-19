# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionsControllerBehavior, type: :controller do
  let(:team_depositor)       { User.create(email: 'teamdepositor@email.com', password: 'password') }
  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                 { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: team_depositor.ms_id) }
  let(:user)                 { User.create(email: 'email@email.com', password: 'password') }

  let(:controller)           { Morphosource::Collections::TeamsController }
  subject { controller.new }

  before do
    allow(user).to receive(:can?).with(:edit, team).and_return(true)
    allow(subject).to receive(:current_user).and_return(user)
    subject.instance_variable_set(:@collection, team)
    Hyrax.config.index_related_works = false
  end

  it 'has an access facet' do
    subject.send(:create_access_facet)
    access_facet = subject.blacklight_config.facet_fields["access_level"]
    expect(access_facet.label).to eq("Access")
  end

  describe 'create_access_facet' do
    let(:public_media)                      { Media.create(title: ['public_media'], visibility: 'open') }
    let(:private_media)                     { Media.create(title: ['private_media'], visibility: 'restricted') }
    let(:deposited_media)                   { Media.create(title: ['deposited_media'], visibility: 'restricted', depositor: user.ms_id) }
    let(:individual_edit_access_media)      { Media.create(title: ['individual_edit_access_media'], visibility: 'restricted') }
    let(:individual_read_access_media)      { Media.create(title: ['individual_read_access_media'], visibility: 'restricted') }
    let(:individual_download_access_media)  { Media.create(title: ['individual_download_access_media'], visibility: 'restricted') }
    let(:group_edit_access_media)           { Media.create(title: ['group_edit_access_media'], visibility: 'restricted') }
    let(:group_read_access_media)           { Media.create(title: ['group_read_access_media'], visibility: 'restricted') }
    let(:group_download_access_media)       { Media.create(title: ['group_download_access_media'], visibility: 'restricted') }

    let(:org)                               { Organization.create(title: ['org']) }
    let(:specimen)                          { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'], organization_id: [org.id])}
    let(:device)                            { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event)                     { ImagingEvent.create(title: ['imaging_event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
    let(:org_media)                         { Media.create(title: ['org_media'], visibility: 'restricted') }

    let(:all_media)                         { [public_media, private_media, deposited_media, individual_edit_access_media, individual_download_access_media, individual_read_access_media, group_edit_access_media, group_download_access_media, group_read_access_media, org_media] }

    let(:collection_media)                  { all_media - [org_media] }

    before do
      another_group = Role.create(name: 'another_group')
      another_group.users << user
      another_group.save

      team.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: team)

      collection_media.each do |m|
        m.member_of_collections += [team]
        Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: m)
      end

      public_media.read_groups += ['public']

      deposited_media.edit_users += [user]

      imaging_event.ordered_members << org_media
      imaging_event.save!

      # give team access to linked org media
      UpdateOrgLinkedTeamMediaAccessJob.perform_now(org_media, team.id)

      individual_edit_access_media.edit_users += [user]

      individual_download_access_media.download_users += [user]

      individual_read_access_media.read_users += [user]

      group_edit_access_media.edit_groups += [another_group.name]

      group_download_access_media.download_groups += [another_group.name]

      group_read_access_media.read_groups += [another_group.name]

      all_media.each(&:save!)
    end

    context 'user is a member of the team' do
      # Putting all scenarios within one test to avoid having to recreate all the works multiple times.
      it "has the correct values in the access facet based on user's team membership" do
        # user is a team manager
        team.managers_group.users << user
        team.managers_group.save!
        subject.send(:create_access_facet)
        # user has edit access to all media added to team
        expect(ids('edit')).to match_array(collection_media.map(&:id))
        # user has download access to no media
        expect(ids('download')).to match_array([])
        # user has read access to all linked org media
        expect(ids('view')).to match_array([org_media.id])
        # reset user team membership and delete access facet
        reset_user_groups_and_facet

        # user is a team editor
        team.editors_group.users << user
        team.editors_group.save!
        user.reload
        subject.send(:create_access_facet)
        # user has edit access to all media added to team
        expect(ids('edit')).to match_array(collection_media.map(&:id))
        # user has download access to no media
        expect(ids('download')).to match_array([])
        # user has read access to all linked org media
        expect(ids('view')).to match_array([org_media.id])
        # reset user team membership and delete access facet
        reset_user_groups_and_facet

        # user is a team depositor
        team.depositors_group.users << user
        team.depositors_group.save!
        user.reload
        subject.send(:create_access_facet)
        # user has edit access to media they deposited and media they have been granted edit access to
        expect(ids('edit')).to match_array([deposited_media.id, group_edit_access_media.id, individual_edit_access_media.id])
        # user has download access to media they have been granted download access to
        expect(ids('download')).to match_array([group_download_access_media.id, individual_download_access_media.id])
        # user has read access to open media, org-linked media and media they have been granted read access to
        expect(ids('view')).to match_array([public_media.id, org_media.id, group_read_access_media.id, individual_read_access_media.id])
        # user does not have access to private media in the collection
        expect(ids('view')).not_to include([private_media.id])
        # reset user team membership and delete access facet
        reset_user_groups_and_facet

        # user is a team downloader
        team.downloaders_group.users << user
        team.downloaders_group.save!
        user.reload
        subject.send(:create_access_facet)
        # user has edit access to media they deposited and media they have been granted edit access to
        expect(ids('edit')).to match_array([deposited_media.id, group_edit_access_media.id, individual_edit_access_media.id])
        # user has download access to all team media except their editable media
        expect(ids('download')).to match_array([group_download_access_media.id, individual_download_access_media.id, public_media.id, private_media.id, group_read_access_media.id, individual_read_access_media.id])
        # user has read access to org-linked media
        expect(ids('view')).to match_array([org_media.id])
        # reset user team membership and delete access facet
        reset_user_groups_and_facet

        # user is a team viewer
        team.viewers_group.users << user
        team.viewers_group.save!
        user.reload
        subject.send(:create_access_facet)
        # user has edit access to media they deposited and media they have been granted edit access to
        expect(ids('edit')).to match_array([deposited_media.id, group_edit_access_media.id, individual_edit_access_media.id])
        # user has download access to media they have been granted download access to
        expect(ids('download')).to match_array([group_download_access_media.id, individual_download_access_media.id])
        # user has read access to org-linked media and all other collection media
        expect(ids('view')).to match_array([org_media.id, public_media.id, private_media.id, group_read_access_media.id, individual_read_access_media.id])
        # reset user team membership and delete access facet
        reset_user_groups_and_facet

        # user is not a member of the team
        user.reload
        subject.send(:create_access_facet)
        # user has edit access to media they deposited and media they have been granted edit access to
        expect(ids('edit')).to match_array([deposited_media.id, group_edit_access_media.id, individual_edit_access_media.id])
        # user has download access to media they have been granted download access to
        expect(ids('download')).to match_array([group_download_access_media.id, individual_download_access_media.id])
        # user has read access to public media and they have been granted read access to
        expect(ids('view')).to match_array([public_media.id, group_read_access_media.id, individual_read_access_media.id])
        # user is not able to see private media they have not been granted access to
        expect(ids('view')).not_to include([private_media.id, org_media.id])
      end
    end
  end

  def access_facet
    subject.blacklight_config.facet_fields["access_level"]
  end

  def filter(access_level)
    access_facet.query[access_level][:fq]
  end

  def ids(access)
    query = "has_model_ssim:Media AND (member_of_collection_ids_ssim:" + team.id + " OR media_organization_id_ssim:" + org.id + ")"
    Morphosource::SolrService.new.get_docs([query], fq: filter(access), fl: ["id"]).map{|d| d["id"]}
  end

  def reset_user_groups_and_facet
    team.user_groups.each do |group|
      group.users.delete(user)
      group.save!
    end
    remove_access_facet
  end

  def remove_access_facet
    subject.blacklight_config.facet_fields.delete('access_level')
  end
end
