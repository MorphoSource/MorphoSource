require 'rails_helper'

RSpec.describe MediaIndexer do

  it 'uses MediaThumbnailPathService' do
    expect(described_class.thumbnail_path_service).to be(Morphosource::MediaThumbnailPathService)
  end

  context 'Solr Document Values' do

    let(:admin_set_id)            { Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s }
    let(:permission_template)     { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }

    let(:depositor)               { FactoryBot.create(:contributor) }
    let(:registered_user)         { FactoryBot.create(:registered_user) }
    let(:owner)                   { FactoryBot.create(:contributor) }

    let(:device)                  { FactoryBot.create(:device, creator: ['Device Make'], title: ['Device Model'], modality: ['Photogrammetry']) }
    let(:device_organization)     { FactoryBot.create(:organization, title: ['Device Organization']) }
    let(:specimen_organization)   { FactoryBot.create(:organization, title: ['Specimen Organization'])}
    let(:file_set)                { FactoryBot.create(:file_set, visibility: 'open') }
    let(:imaging_event)           { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: device.modality, physical_object_id: [specimen.id])}
    let(:parent_media)            { FactoryBot.create(:media) }
    let(:processing_event1)       { FactoryBot.create(:processing_event) }
    let(:processing_event2)       { FactoryBot.create(:processing_event) }
    let(:specimen)                { FactoryBot.create(:biological_specimen,
                                                       catalog_number: ['1234'],
                                                       collection_code: ['ABC'],
                                                       institution_code: ['XYZ'],
                                                       organization_id: [specimen_organization.id],
                                                       occurrence_id: ['ABC:1234'],
                                                       taxonomy_id: [taxonomy.id]) }
    let(:taxonomy)                { valkyrie_create(:taxonomy_resource, title: ['genus species']) }

    let(:project)                 { FactoryBot.create(:project, visibility: 'open', depositor: depositor.ms_id) }
    let(:team)                    { FactoryBot.create(:team, visibility: 'open', depositor: depositor.ms_id) }
    let(:media_list)              { FactoryBot.create(:media_list, visibility: 'open', depositor: depositor.ms_id) }
    let(:sequential_section_list) { FactoryBot.create(:sequential_section_list, visibility: 'open', depositor: depositor.ms_id) }
    let(:collections)             { [project, team, media_list, sequential_section_list]}

    let(:media_attributes)        { { admin_set_id: admin_set_id,
                                      agreement_uri: ["https://mcz.harvard.edu/permissions-copyright"],
                                      ark: ["ark:/12345/m4/678910"],
                                      available: ['yes'],
                                      cite_as: ['cite as'],
                                      creator: [depositor.display_name],
                                      date_created: ["2023-01-01"],
                                      date_modified: "2023-05-05 12:03:17",
                                      depositor: depositor.ms_id,
                                      description: ['description'],
                                      doi: ['doi'],
                                      download_reviewer: ['1234'],
                                      fileset_visibility: ['open'],
                                      fileset_accessibility: ['restricted_download'],
                                      funding: ['funding'],
                                      identifier: ['identifier'],
                                      keyword: ['red', 'yellow', 'blue'],
                                      legacy_media_file_id: ['oldfileid'],
                                      legacy_media_group_id: ['oldgroupid'],
                                      license: ["https://creativecommons.org/licenses/by-nc-nd/4.0/"],
                                      map_type: ['map type'],
                                      media_type: ["Mesh"],
                                      morphosource_use_agreement_type: ["Standard"],
                                      number_of_images_in_set: '5',
                                      organization_transfer_on_publish: false,
                                      orientation: ['Left'],
                                      owner: owner.ms_id,
                                      part: ['Toe'],
                                      permits_3d_use: ["3DPrintingLimited"],
                                      permits_commercial_use: ["CommercialUseNotPermitted"],
                                      preview_mode: ["Interactive/Embeddable"],
                                      publisher: ["Museum of Comparative Zoology"],
                                      related_url: ['www.apple.com'],
                                      remote_manifest_url: 'https://github.com/',
                                      remote_origin_url: 'https://www.google.com',
                                      required_archival_of_published_derivatives: ["OnMorphoSource"],
                                      rights_holder: ["President and Fellows (Copyright and License)"],
                                      rights_statement: ["http://rightsstatements.org/vocab/InC/1.0/"],
                                      scale_bar: ['scale bar'],
                                      series_type: ['series type'],
                                      short_description: ['short description'],
                                      side: ["Left"],
                                      slice_thickness: ['slice thickness'],
                                      title: ['New Media'],
                                      unit: ["Cm"],
                                      uuid: ['uuid'],
                                      visibility: 'open',
                                      x_spacing: ['x spacing'],
                                      y_spacing: ['y spacing'],
                                      z_spacing: ['z spacing'] } }

    let(:media)                   { Media.new(media_attributes) }

    subject                       { SolrDocument.find(media.id) }

    # specimen
    # imaging_event
    #  - processing_event1
    #    - parent_media
    #      - processing_event2
    #        - media

    before do
      Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(media, ::Ability.new(depositor), {}))
      media.keyword = ['red', 'yellow', 'blue'] # TODO: keyword is disappearing from media if added before Hyrax::CurationConcern.actor.create
      media.download_users += [registered_user]
      add_ordered_members(device_organization, device)
      add_ordered_members(imaging_event, processing_event1)
      add_ordered_members(processing_event1, parent_media)
      add_ordered_members(parent_media, processing_event2)
      add_ordered_members(processing_event2, media)
      collections.each do |c|
        c.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: c)
        c.add_member_objects(media)
      end
      add_ordered_members(media, file_set)
    end

    it 'indexes expected values' do
      expect(subject['accessControl_ssim']).to match_array([media.access_control.id])
      expect(subject['actionable_workflow_roles_ssim']).to match_array(['admin_set_default-default-managing', 'admin_set_default-default-approving', 'admin_set_default-default-depositing'])
      expect(subject['active_fund_code_title_ssim']).to match_array(["MorphoSource"])
      expect(subject['admin_set_ssim']).to match_array(media.admin_set.title)
      expect(subject['admin_set_tesim']).to match_array(media.admin_set.title)
      expect(subject['agreement_uri_tesim']).to match_array(media.agreement_uri)
      expect(subject['ark_ssim']).to match_array(media.ark)
      expect(subject['ark_tesim']).to match_array(media.ark)
      expect(subject['available_tesim']).to match_array(media.available)
      expect(subject['catalog_number_ssim']).to match_array(specimen.catalog_number)
      expect(subject['catalog_number_tesim']).to match_array(specimen.catalog_number)
      expect(subject['cite_as_tesim']).to match_array(media.cite_as)
      expect(subject['collection_code_ssim']).to match_array(specimen.collection_code)
      expect(subject['collection_code_tesim']).to match_array(specimen.collection_code)
      expect(subject['creator_ssim']).to match_array(media.creator)
      expect(subject['creator_tesim']).to match_array(media.creator)
      expect(subject['date_created_tesim']).to match_array(media.date_created)
      expect(subject['date_modified_dtsi']).to eq(media.date_modified.strftime("%FT%R:%SZ"))
      expect(subject['date_uploaded_dtsi']).to be_a_kind_of(String)
      expect(subject['depositor_email_ssim']).to match_array([depositor.email])
      expect(subject['depositor_email_tesim']).to match_array([depositor.email])
      expect(subject['depositor_name_ssim']).to match_array([depositor.display_name])
      expect(subject['depositor_name_tesim']).to match_array([depositor.display_name])
      expect(subject['depositor_ssim']).to match_array([media.depositor])
      expect(subject['depositor_tesim']).to match_array([media.depositor])
      expect(subject['description_tesim']).to match_array(media.description)
      expect(subject['download_access_group_ssim']).to match_array ([project.downloaders_group.name, team.downloaders_group.name])
      expect(subject['download_access_person_ssim']).to match_array([registered_user.ms_id])
      expect(subject['doi_ssim']).to match_array(media.doi)
      expect(subject['download_reviewer_ssim']).to match_array(media.download_reviewer)
      expect(subject['download_reviewer_tesim']).to match_array(media.download_reviewer)
      expect(subject['edit_access_group_ssim']).to match_array(['admin', team.managers_group.name, team.editors_group.name, project.managers_group.name, project.editors_group.name])
      expect(subject['edit_access_person_ssim']).to match_array([media.depositor])
      expect(subject['file_set_ids_ssim']).to match_array(media.file_set_ids)
      expect(subject['file_set_visibilities_ssim']).to match_array([media.visibility])
      expect(subject['fileset_accessibility_ssim']).to match_array(media.fileset_accessibility)
      expect(subject['fileset_accessibility_tesim']).to match_array(media.fileset_accessibility)
      expect(subject['fileset_visibility_tesim']).to match_array(media.fileset_visibility)
      expect(subject['funding_tesim']).to match_array(media.funding)
      expect(subject['generic_type_ssim']).to match_array(['Work'])
      expect(subject['has_model_ssim']).to match_array(['Media'])
      expect(subject['human_readable_media_type_ssi']).to eq(media.human_readable_media_type&.first&.downcase)
      expect(subject['human_readable_media_type_ssim']).to match_array(media.media_type)
      expect(subject['human_readable_media_type_tesim']).to match_array(media.media_type)
      expect(subject['human_readable_modality_tesim']).to match_array([media.modality_label])
      expect(subject['human_readable_type_ssi']).to eq(media.human_readable_type)
      expect(subject['human_readable_type_tesim']).to match_array([media.human_readable_type])
      expect(subject['id']).to eq(media.id)
      expect(subject['identifier_tesim']).to match_array(media.identifier)
      expect(subject['imaging_event_id_tesim']).to match_array([imaging_event.id])
      expect(subject['institution_code_ssim']).to match_array(specimen.institution_code)
      expect(subject['institution_code_tesim']).to match_array(specimen.institution_code)
      expect(subject['isPartOf_ssim']).to match_array([admin_set_id])
      expect(subject['is_remote_backed_bsi']).to eq(true)
      expect(subject['keyword_ssim']).to match_array(media.keyword)
      expect(subject['keyword_tesim']).to match_array(media.keyword)
      expect(subject['legacy_media_file_id_tesim']).to match_array(media.legacy_media_file_id)
      expect(subject['legacy_media_group_id_tesim']).to match_array(media.legacy_media_group_id)
      expect(subject['license_ssim']).to match_array(media.license)
      expect(subject['license_tesim']).to match_array(media.license)
      expect(subject['map_type_ssim']).to match_array(media.map_type)
      expect(subject['map_type_tesim']).to match_array(media.map_type)
      expect(subject['media_device_facility_organization_id_ssim']).to match_array([device_organization.id])
      expect(subject['media_device_facility_organization_id_tesim']).to match_array([device_organization.id])
      expect(subject['media_device_facility_organization_ssim']).to match_array(device_organization.title)
      expect(subject['media_device_facility_organization_tesim']).to match_array(device_organization.title)
      expect(subject['media_device_id_ssim']).to match_array([device.id])
      expect(subject['media_device_id_tesim']).to match_array([device.id])
      expect(subject['media_device_ssim']).to match_array(["#{device.creator.first} #{device.title.first}"])
      expect(subject['media_device_tesim']).to match_array(["#{device.creator.first} #{device.title.first}"])
      expect(subject['media_organization_id_ssim']).to match_array(specimen.organization_id)
      expect(subject['media_organization_id_tesim']).to match_array(specimen.organization_id)
      expect(subject['media_organization_ssim']).to match_array(specimen_organization.title)
      expect(subject['media_organization_tesim']).to match_array(specimen_organization.title)
      expect(subject['media_parent_id_ssim']).to match_array([parent_media.id])
      expect(subject['media_physical_object_type_ssim']).to match_array(['Biological Specimen'])
      expect(subject['media_physical_object_type_tesim']).to match_array(['Biological Specimen'])
      expect(subject['media_type_ssim']).to match_array(media.media_type)
      expect(subject['media_type_tesim']).to match_array(media.media_type)
      expect(subject['member_of_public_collection_ids_ssim']).to match_array(collections.map(&:id))
      expect(subject['member_of_team_ids_ssim']).to match_array([team.id])
      expect(subject['member_of_project_ids_ssim']).to match_array([project.id])
      expect(subject['member_of_media_list_ids_ssim']).to match_array([media_list.id])
      expect(subject['member_of_sequential_section_list_ids_ssim']).to match_array([sequential_section_list.id])
      expect(subject['modality_ssim']).to match_array(imaging_event.ie_modality)
      expect(subject['morphosource_use_agreement_type_tesim']).to match_array(media.morphosource_use_agreement_type)
      expect(subject['number_of_images_in_set_tesim']).to match_array(media.number_of_images_in_set)
      expect(subject['occurrence_id_ssim']).to match_array(specimen.occurrence_id)
      expect(subject['occurrence_id_tesim']).to match_array(specimen.occurrence_id)
      expect(subject['organization_transfer_on_publish_bsi']).to eq(media.organization_transfer_on_publish)
      expect(subject['orientation_tesim']).to match_array(media.orientation)
      expect(subject['owner_ssim']).to match_array([media.owner])
      expect(subject['owner_type_ssi']).to eq(owner.class.to_s)
      expect(subject['part_ssi']).to eq(media.part&.first&.downcase)
      expect(subject['part_tesim']).to match_array(media.part)
      expect(subject['permits_3d_use_tesim']).to match_array(media.permits_3d_use)
      expect(subject['permits_commercial_use_tesim']).to match_array(media.permits_commercial_use)
      expect(subject['physical_object_id_ssim']).to match_array([specimen.id])
      expect(subject['physical_object_id_tesim']).to match_array(specimen.id)
      expect(subject['physical_object_title_ssi']).to eq(specimen.title&.first&.downcase)
      expect(subject['physical_object_title_ssim']).to match_array(specimen.title)
      expect(subject['physical_object_title_tesim']).to match_array(specimen.title)
      expect(subject['preview_mode_tesim']).to match_array(media.preview_mode)
      expect(subject['publication_status_ssi']).to eq('Restricted Download')
      expect(subject['publisher_ssim']).to match_array(media.publisher)
      expect(subject['publisher_tesim']).to match_array(media.publisher)
      expect(subject['read_access_group_ssim']).to match_array(['public', team.viewers_group.name, project.viewers_group.name])
      expect(subject['related_url_tesim']).to match_array(media.related_url)
      expect(subject['remote_manifest_url_ssi']).to eq(media.remote_manifest_url)
      expect(subject['required_archival_of_published_derivatives_tesim']).to match_array(media.required_archival_of_published_derivatives)
      expect(subject['rights_holder_tesim']).to match_array(media.rights_holder)
      expect(subject['rights_statement_ssim']).to match_array(media.rights_statement)
      expect(subject['rights_statement_tesim']).to match_array(media.rights_statement)
      expect(subject['scale_bar_tesim']).to match_array(media.scale_bar)
      expect(subject['series_type_ssim']).to match_array(media.series_type)
      expect(subject['series_type_tesim']).to match_array(media.series_type)
      expect(subject['short_description_ssim']).to match_array(media.short_description)
      expect(subject['short_description_tesim']).to match_array(media.short_description)
      expect(subject['side_ssim']).to match_array(media.side)
      expect(subject['side_tesim']).to match_array(media.side)
      expect(subject['slice_thickness_tesim']).to match_array(media.slice_thickness)
      expect(subject['suppressed_bsi']).to be(false)
      expect(subject['system_create_dtsi']).to be_a_kind_of(String)
      expect(subject['system_modified_dtsi']).to be_a_kind_of(String)
      expect(subject['taxonomy_ssi']).to eq(taxonomy.title&.first&.downcase)
      expect(subject['taxonomy_ssim']).to match_array(taxonomy.title)
      expect(subject['taxonomy_tesim']).to match_array(taxonomy.title)
      expect(subject['thumbnail_path_ss']).to eq(Morphosource::MediaThumbnailPathService.call(media))
      expect(subject['timestamp']).to be_a_kind_of(String)
      expect(subject['title_ssi']).to eq(media.title.first)
      expect(subject['title_tesim']).to match_array(media.title)
      expect(subject['unit_ssim']).to match_array(media.unit)
      expect(subject['uuid_tesim']).to match_array(media.uuid)
      expect(subject['user_with_ownership_email_ssim']).to match_array([owner.email])
      expect(subject['user_with_ownership_email_tesim']).to match_array([owner.email])
      expect(subject['user_with_ownership_name_ssim']).to match_array(owner.display_name)
      expect(subject['user_with_ownership_name_tesim']).to match_array(owner.display_name)
      expect(subject['user_with_ownership_ssi']).to eq(owner.ms_id)
      expect(subject['visibility_ssi']).to eq(media.visibility)
      expect(subject['workflow_state_name_ssim']).to match_array(['deposited'])
      expect(subject['x_spacing_tesim']).to match_array(media.x_spacing)
      expect(subject['y_spacing_tesim']).to match_array(media.y_spacing)
      expect(subject['z_spacing_tesim']).to match_array(media.z_spacing)
    end
  end

  describe 'publication status' do
    let(:media) { FactoryBot.create(:media) }
    subject     { described_class.new(media).generate_solr_document }
    context 'media is open' do
      before do
        media.fileset_accessibility = ['open']
      end
      it 'is Open Download' do
        expect(subject['publication_status_ssi']).to eq('Open Download')
      end
    end
    context 'media is resticted download' do
      before do
        media.fileset_accessibility = ['restricted_download']
      end
      it 'is Restricted Download' do
        expect(subject['publication_status_ssi']).to eq('Restricted Download')
      end
    end
    context 'media is private' do
      before do
        media.fileset_accessibility = ['private']
      end
      it 'is Private' do
        expect(subject['publication_status_ssi']).to eq('Private')
      end
    end
  end

  describe 'organization fields' do
    let(:device)          { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:imaging_event)   { FactoryBot.create(:imaging_event, title: ['imaging event'], ie_modality: device.modality, physical_object_id: [specimen.id], device_id: [device.id]) }
    let(:media)           { Media.create(title: ['media']) }
    subject               { SolrDocument.find(media.id) }

    context 'organization is a work' do
      let(:organization)  { FactoryBot.create(:organization, title: ['organization work'], institution_name: ['institution name']) }

      before do
        organization.ordered_members << device
        organization.save!
        imaging_event.ordered_members << media
        imaging_event.save!
        media.update_index
      end

      it 'indexes organization fields' do
        expect(subject['media_organization_tesim']).to match_array(organization.title)
        expect(subject['media_organization_ssim']).to match_array(organization.title)
        expect(subject['media_organization_id_ssim']).to match_array([organization.id])
        expect(subject['media_organization_id_tesim']).to match_array([organization.id])
        expect(subject['media_device_facility_organization_tesim']).to match_array(organization.title)
        expect(subject['media_device_facility_organization_ssim']).to match_array(organization.title)
        expect(subject['media_device_facility_organization_id_tesim']).to match_array(organization.id)
        expect(subject['media_device_facility_organization_id_ssim']).to match_array(organization.id)
      end
    end

    context 'organization is a collection' do
      let(:user)          { FactoryBot.create(:contributor) }
      let(:organization)  { FactoryBot.create(:organization_collection, title: ['organization work'], institution_name: ['institution name'], depositor: user.ms_id) }

      before do
        device.organization_id = [organization.id]
        device.save!
        imaging_event.ordered_members << media
        imaging_event.save!
        media.update_index
      end

      it 'indexes organization fields' do
        expect(subject['media_organization_tesim']).to match_array(organization.title)
        expect(subject['media_organization_ssim']).to match_array(organization.title)
        expect(subject['media_organization_id_ssim']).to match_array([organization.id])
        expect(subject['media_organization_id_tesim']).to match_array([organization.id])
        expect(subject['media_device_facility_organization_tesim']).to match_array(organization.title)
        expect(subject['media_device_facility_organization_ssim']).to match_array(organization.title)
        expect(subject['media_device_facility_organization_id_tesim']).to match_array(organization.id)
        expect(subject['media_device_facility_organization_id_ssim']).to match_array(organization.id)
      end
    end
  end

  # helper method
  def add_ordered_members(parent, child)
    parent.ordered_members << child
    parent.save!
  end

  describe 'media_owner' do
    let(:depositor) { FactoryBot.create(:contributor) }
    let(:media)     { Media.new(depositor: depositor.ms_id) }

    context 'media has a depositor only' do
      it 'indexes depositor as owner' do
        expect(described_class.new(media).media_owner).to eq(depositor)
      end
    end
    context 'media has a depositor and an owner' do
      context 'owner is a user' do
        let(:owner)     { FactoryBot.create(:contributor) }
        before { media.owner = owner.ms_id }
        it 'indexes owner as owner' do
          expect(described_class.new(media).media_owner).to eq(owner)
        end
      end
      context 'owner is an organization' do
        let(:owner)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id) }
        before { media.owner = owner.id }
        it 'indexes depositor as owner' do
          expect(described_class.new(media).media_owner).to eq(owner)
        end
      end
    end
  end
end
