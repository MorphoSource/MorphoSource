require "rails_helper"
require 'rake'

describe 'morphosource rake tasks' do
  let(:setup)                     { Rake::Task['morphosource:setup'] }
  let(:create_admin_set)          { Rake::Task['hyrax:default_admin_set:create'] }
  let(:create_collection_types)   { Rake::Task['morphosource:create_collection_types'] }
  let(:create_admin_role)         { Rake::Task['morphosource:create_admin_role'] }
  let(:create_contributor_role)   { Rake::Task['morphosource:create_contributor_role'] }
  let(:create_development_users)  { Rake::Task['morphosource:create_development_users'] }
  let(:create_production_users)   { Rake::Task['morphosource:create_production_users'] }
  let(:update_media_ip_holder)    { Rake::Task['morphosource:update_media_ip_holder'] }
  let(:find_extra_solr_records)   { Rake::Task['morphosource:find_extra_solr_records'] }
  let(:find_and_merge_duplicate_specimens) { Rake::Task['morphosource:find_and_merge_duplicate_specimens'] }
  let(:tasks)                     { [setup, create_admin_set, create_collection_types, create_admin_role, create_contributor_role, create_development_users, create_production_users, update_media_ip_holder, find_extra_solr_records, find_and_merge_duplicate_specimens] }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    tasks.each(&:reenable)
    # reset collection type count to 0
    Hyrax::CollectionType.destroy_all
  end

  describe "morphosource:create_collection_types", type: :task do
    let(:team_settings)                     { Morphosource::CollectionTypes::Teams::SETTINGS }
    let(:project_settings)                  { Morphosource::CollectionTypes::Projects::SETTINGS }
    let(:media_list_settings)               { Morphosource::CollectionTypes::MediaLists::SETTINGS }
    let(:sequential_section_list_settings)  { Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS }
    let(:organization_settings)             { Morphosource::CollectionTypes::Organizations::SETTINGS }
    let(:types)                             { Hyrax::CollectionType.all }
    let(:team_type)                         { types.find{|t| t[:title] == "Team"} }
    let(:project_type)                      { types.find{|t| t[:title] == "Project"} }
    let(:media_list_type)                   { types.find{|t| t[:title] == "Media List"} }
    let(:sequential_section_list_type)      { types.find{|t| t[:title] == "Sequential Section List"} }
    let(:organization_type)                 { types.find{|t| t[:title] == "Organization"} }
    let(:type_settings)                     { [ { type: team_type, settings: team_settings }, { type: project_type, settings: project_settings }, { type: media_list_type, settings: media_list_settings }, { type: sequential_section_list_type, settings: sequential_section_list_settings }, { type: organization_type, settings: organization_settings } ] }

    it 'creates collection types' do
      expect { create_collection_types.invoke }.to change { Hyrax::CollectionType.count }.by(5)
    end

    it 'assigns the correct attribute values' do
      create_collection_types.invoke

      type_settings.each do |t|
        type = t[:type]
        settings = t[:settings]

        expect(type.title).to eq(settings[:title])
        expect(type.description).to eq(settings[:description])
        expect(type.machine_id).to eq(settings[:machine_id])
        expect(type.nestable).to be(settings[:nestable])
        expect(type.discoverable).to be(settings[:discoverable])
        expect(type.sharable).to be(settings[:sharable])
        expect(type.allow_multiple_membership).to be(settings[:allow_multiple_membership])
        expect(type.require_membership).to be(settings[:require_membership])
        expect(type.assigns_workflow).to be(settings[:assigns_workflow])
        expect(type.assigns_visibility).to be(settings[:assigns_visibility])
        expect(type.share_applies_to_new_works).to be(settings[:share_applies_to_new_works])
        expect(type.brandable).to be(settings[:brandable])
        expect(type.badge_color).to eq(settings[:badge_color])
      end
    end

    it "assigns manager and creator participants" do
      create_collection_types.invoke

      types.each do |type|
        participants = type.collection_type_participants
        managers = participants.select{|p| p.agent_id == 'admin' && p.access == 'manage'}
        creators = participants.select{|p| p.agent_id == 'registered' && p.access == 'create'}

        expect(participants.count).to eq(2)
        expect(managers.count).to eq(1)
        expect(creators.count).to eq(1)
      end
    end
  end

  describe "morphosource:create_contributor_role", type: :task do

    context 'contributor role does not exist' do
      it "creates a contributor role" do
        expect(Role).to receive(:create).with(name: 'contributor').and_return(true)
        create_contributor_role.invoke
      end
    end

    context 'contributor role already exists' do
      before do
        Role.create(name: 'contributor')
      end
      it "does not create a contributor role" do
        expect(Role).not_to receive(:create)
        create_contributor_role.invoke
      end
    end
  end

  describe 'create_development_users', type: :task do
    let(:defaults)              { Morphosource::Users::Defaults }
    let(:admin_defaults)        { defaults::ADMIN }
    let(:contributor_defaults)  { defaults::CONTRIBUTOR }
    let(:registered_defaults)   { defaults::REGISTERED }
    let(:admin)                 { User.find_by(email: admin_defaults[:email]) }
    let(:contributor)           { User.find_by(email: contributor_defaults[:email]) }
    let(:registered)            { User.find_by(email: registered_defaults[:email]) }
    let(:user_settings)         { [
      { user: admin, settings: admin_defaults },
      { user: contributor, settings: contributor_defaults },
      { user: registered, settings: registered_defaults } ] }

    before do
      stub_const('Morphosource::Users::Defaults::ADMIN', defaults::ADMIN.except(:id))
      stub_const('Morphosource::Users::Defaults::CONTRIBUTOR', defaults::CONTRIBUTOR.except(:id))
      stub_const('Morphosource::Users::Defaults::REGISTERED', defaults::REGISTERED.except(:id))
    end

    it 'creates admin, contributor, registered, and email users (if contact email present)' do
      if Hyrax.config.contact_email.present? # 4 users created if contact email present
        expect { create_development_users.invoke }.to change { User.count }.by(4)
      else
        expect { create_development_users.invoke }.to change { User.count }.by(3)
      end
    end

    it 'assigns the new users appropriate roles' do
      create_development_users.invoke
      expect(admin.admin?).to be(true)
      expect(contributor.contributor?).to be(true)
      expect(registered.registered?).to be(true)
    end

    it 'assigns the new users the correct values' do
      create_development_users.invoke

      user_settings.each do |u|
        user = u[:user]
        defaults = u[:settings]

        expect(user.email).to eq(defaults[:email])
        expect(user.guest).to eq(defaults[:guest])
        expect(user.facebook_handle).to eq(defaults[:facebook_handle])
        expect(user.twitter_handle).to eq(defaults[:twitter_handle])
        expect(user.display_name).to eq(defaults[:display_name])
        expect(user.address).to eq(defaults[:address])
        expect(user.department).to eq(defaults[:department])
        expect(user.website).to eq(defaults[:website])
        expect(user.affiliation).to eq(defaults[:affiliation])
        expect(user.telephone).to eq(defaults[:telephone])
        expect(user.orcid).to eq(defaults[:orcid])
        expect(user.state).to eq(defaults[:state])
        expect(user.country).to eq(defaults[:country])
        expect(user.postal_code).to eq(defaults[:postal_code])
        expect(user.terms_read).to eq(defaults[:terms_read])
        expect(user.ms1_user).to eq(defaults[:ms1_user])
      end
    end
  end

  describe "morphosource:create_admin_role", type: :task do

    context 'admin role does not exist' do
      it "creates an admin role" do
        expect(Role).to receive(:create).with(name: 'admin').and_return(true)
        create_admin_role.invoke
      end
    end

    context 'admin role already exists' do
      before do
        Role.create(name: 'admin')
      end
      it "does not create a contributor role" do
        expect(Role).not_to receive(:create)
        create_admin_role.invoke
      end
    end
  end

  describe 'setup' do

    context 'when development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'calls the appropriate tasks' do
        expect(create_admin_set).to receive(:invoke)
        expect(create_collection_types).to receive(:invoke)
        expect(create_admin_role).to receive(:invoke)
        expect(create_contributor_role).to receive(:invoke)
        setup.invoke
      end
    end
  end

  describe 'update_media_ip_holder' do
    let(:rh_1)    { ["Name: Rights Holder Name, Type: Copyright and License"] }
    let(:rh_2)    { ["Name: Name, with, commas, Type: License"] }
    let(:rh_3)    { ["Name: Name: with: colons:, Type: Copyright"] }
    let(:rh_4)    { ["Name: , Type: "] }
    let(:rh_5)    { ["Name: name without type information, Type: "] }
    let(:rh_6)    { ["Name: , Type: Copyright and License"] }
    let(:rh_7)    { ["Name: multiple rights holder 1, Type: Copyright", "Name: multiple rights holder 2, Type: License", "Name: multiple rights holder 3, Type: Copyright and License"] }
    let(:rh_8)    { ["just a bunch of text without name and license"] }
    let(:rh_9)    { ["a bunch of text with Name: in the middle"] }
    let(:rh_10)   { ["a bunch of text with Type: in the middle"] }
    let(:rh_11)   { ["Name:namewithoutspaces, Type:typewithoutspaces"] }

    let(:formatted_rh1) { ["Rights Holder Name (Copyright and License)"] }
    let(:formatted_rh2) { ["Name, with, commas (License)"] }
    let(:formatted_rh3) { ["Name: with: colons: (Copyright)"] }
    let(:formatted_rh4) { [] }
    let(:formatted_rh5) { ["name without type information"] }
    let(:formatted_rh6) { [] }
    let(:formatted_rh7) { ["multiple rights holder 1 (Copyright)", "multiple rights holder 2 (License)", "multiple rights holder 3 (Copyright and License)"] }

    # these should get updated
    let(:media1)  { Media.create(title: ['media1'], rights_holder: rh_1)}
    let(:media2)  { Media.create(title: ['media2'], rights_holder: rh_2)}
    let(:media3)  { Media.create(title: ['media3'], rights_holder: rh_3)}
    let(:media4)  { Media.create(title: ['media4'], rights_holder: rh_4)}
    let(:media5)  { Media.create(title: ['media5'], rights_holder: rh_5)}
    let(:media6)  { Media.create(title: ['media6'], rights_holder: rh_6)}
    let(:media7)  { Media.create(title: ['media7'], rights_holder: rh_7)}

    # these should not get updated
    let(:media8)  { Media.create(title: ['media8'], rights_holder: rh_8)}
    let(:media9)  { Media.create(title: ['media9'], rights_holder: rh_9)}
    let(:media10) { Media.create(title: ['media10'], rights_holder: rh_10)}
    let(:media11) { Media.create(title: ['media10'], rights_holder: rh_11)}

    let!(:media) { [media1, media2, media3, media4, media5, media6, media7, media8, media9, media10, media11] }

    context 'when development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'transforms name, type formatted rights_holder' do
        update_media_ip_holder.invoke
        media.each(&:reload)

        expect(media1.rights_holder).to match_array(formatted_rh1)
        expect(media2.rights_holder).to match_array(formatted_rh2)
        expect(media3.rights_holder).to match_array(formatted_rh3)
        expect(media4.rights_holder).to match_array(formatted_rh4)
        expect(media5.rights_holder).to match_array(formatted_rh5)
        expect(media6.rights_holder).to match_array(formatted_rh6)
        expect(media7.rights_holder).to match_array(formatted_rh7)

        expect(media8.rights_holder).to match_array(rh_8)
        expect(media9.rights_holder).to match_array(rh_9)
        expect(media10.rights_holder).to match_array(rh_10)
        expect(media11.rights_holder).to match_array(rh_11)
      end
    end
  end

  describe 'find_extra_solr_records' do
    it 'calls Morphosource::FindExtraSolrJob' do
      expect(Morphosource::FindExtraSolrJob).to receive(:perform_later)
      find_extra_solr_records.invoke
    end
  end

  describe 'find_and_merge_duplicate_specimens', type: :task do
    around do |example|
      previous_recipients = Hyrax.config.system_report_recipients
      example.run
      Hyrax.config.system_report_recipients = previous_recipients
    end

    before do
      ActionMailer::Base.deliveries.clear
    end

    context 'when the send_email arg is not the string "true"' do
      before { Hyrax.config.system_report_recipients = 'test@example.com' }

      it 'does not send an email' do
        find_and_merge_duplicate_specimens.invoke('merge_report_only', 'false')
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'when system_report_recipients is not configured' do
      before { Hyrax.config.system_report_recipients = '' }

      it 'does not send an email' do
        find_and_merge_duplicate_specimens.invoke('merge_report_only', 'true')
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'when send_email is "true" and recipients are configured' do
      before { Hyrax.config.system_report_recipients = 'test@example.com' }

      it 'sends an email with the report log attached' do
        find_and_merge_duplicate_specimens.invoke('merge_report_only', 'true')
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to).to eq(['test@example.com'])
        expect(ActionMailer::Base.deliveries.first.attachments).not_to be_empty
      end
    end

    context 'when duplicate specimens exist and merge is requested' do
      let!(:specimen) do
        [
          BiologicalSpecimen.create(title: ['dup a'], catalog_number: ['1'], institution_code: ['INST'],
                                     collection_code: ['abc'], vouchered: ['Yes'],
                                     occurrence_id: ['urn:catalog:dual-logger-spec:1'], idigbio_uuid: ['dual-logger-spec-uuid']),
          BiologicalSpecimen.create(title: ['dup b'], catalog_number: ['2'], institution_code: ['INST'],
                                     collection_code: ['abc'], vouchered: ['Yes'],
                                     occurrence_id: ['urn:catalog:dual-logger-spec:1'], idigbio_uuid: ['dual-logger-spec-uuid'])
        ]
      end

      before do
        specimen.each(&:save)
        specimen.each(&:reload)
        ActiveFedora::SolrService.commit
        Hyrax.config.system_report_recipients = ''
      end

      it 'invokes MergeBiologicalSpecimenService for the duplicate pair' do
        expect(Morphosource::MergeBiologicalSpecimenService).to receive(:call)
          .with(a_string_matching(/\A0*[a-z0-9]+\z/i), a_string_matching(/\A0*[a-z0-9]+\z/i), true, false)
          .and_return([[], [], :destroyed])
        find_and_merge_duplicate_specimens.invoke('true', 'false')
      end

      context 'and the merge service raises (e.g. an ImagingEvent failed to reassign)' do
        before { Hyrax.config.system_report_recipients = 'test@example.com' }

        it 'sends a failure email and re-raises to fail the task' do
          allow(Morphosource::MergeBiologicalSpecimenService).to receive(:call).and_raise('boom')

          expect { find_and_merge_duplicate_specimens.invoke('true', 'true') }.to raise_error('boom')

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.to).to eq(['test@example.com'])
          expect(ActionMailer::Base.deliveries.first.subject).to include('FAILED')
          expect(ActionMailer::Base.deliveries.first.subject).to include('[ATTENTION]')
          expect(ActionMailer::Base.deliveries.first.attachments).not_to be_empty
        end
      end

      context 'and the merge service returns a not_destroyed_media_referencing outcome' do
        before { Hyrax.config.system_report_recipients = 'test@example.com' }

        it 'flags the email as needing attention' do
          allow(Morphosource::MergeBiologicalSpecimenService).to receive(:call)
            .and_return([[], [], :not_destroyed_media_referencing])

          find_and_merge_duplicate_specimens.invoke('true', 'true')

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to include('[ATTENTION]')
          expect(ActionMailer::Base.deliveries.first.text_part.body.to_s).to include('NOT destroyed')
        end
      end

      context 'and the merge service returns a not_destroyed_pending_reindex outcome' do
        before { Hyrax.config.system_report_recipients = 'test@example.com' }

        it 'flags the email as needing attention' do
          allow(Morphosource::MergeBiologicalSpecimenService).to receive(:call)
            .and_return([[], [], :not_destroyed_pending_reindex])

          find_and_merge_duplicate_specimens.invoke('true', 'true')

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to include('[ATTENTION]')
          expect(ActionMailer::Base.deliveries.first.text_part.body.to_s).to include('NOT destroyed')
        end
      end

      context 'and the merge service returns a not_destroyed_has_media_guard outcome' do
        before { Hyrax.config.system_report_recipients = 'test@example.com' }

        it 'flags the email as needing attention' do
          allow(Morphosource::MergeBiologicalSpecimenService).to receive(:call)
            .and_return([[], [], :not_destroyed_has_media_guard])

          find_and_merge_duplicate_specimens.invoke('true', 'true')

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first.subject).to include('[ATTENTION]')
          expect(ActionMailer::Base.deliveries.first.text_part.body.to_s).to include('NOT destroyed')
        end
      end
    end
  end
end
