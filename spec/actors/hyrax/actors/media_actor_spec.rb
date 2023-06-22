# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::Actors::MediaActor do
  let(:next_actor) { double(create: true, update: true) }

  subject { described_class.new(next_actor) }

  describe '#create' do
    let(:work) { Media.new }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
      allow(subject).to receive(:split_keywords) { ['one','two','three'] }
    end
    it 'changes the title attribute' do
      expect { subject.create(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
    end
    it 'changes the keyword attribute' do
      expect { subject.create(env) }.to change{env.attributes['keyword']}.to([ 'one','two','three' ])
    end

    describe 'adding view access to linked teams' do
      context 'media is created without a parent work' do
        before do
          env.attributes[:work_parents_attributes] = nil
        end
        it 'does not call #find_organization' do
          expect(subject).not_to receive(:find_parent).with(env)
          subject.create(env)
        end
      end
      context 'media is created through the submission process' do
        let(:device)              { Device.create(title: ['device'], modality: ['Photogrammetry']) }
        let(:taxonomy)            { Taxonomy.create(title: ['taxonomy']) }
        let(:biological_specimen) { BiologicalSpecimen.create(title: ['title'], vouchered: [ "Yes" ], taxonomy_id: [taxonomy.id]) }
        let(:imaging_event)       { ImagingEvent.create(title: ['imaging_event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [biological_specimen.id]) }
        let(:processing_event)    { ProcessingEvent.create(title: ['processing event']) }


        before do
          imaging_event.ordered_members << processing_event
          [processing_event, imaging_event].each(&:save)

          env.attributes[:work_parents_attributes] = { '1' => { 'id' => processing_event.id, '_destroy' => 'false' } }
        end

        context 'media is associated with a specimen that does not belong to an organization' do
          it 'does not call #add_organization_team_access' do
            expect(subject).to receive(:add_team_access).with(env).and_call_original
            expect(subject).to receive(:find_parent).with(env).and_call_original
            expect(subject).not_to receive(:add_organization_team_access)
            subject.create(env)
          end
        end

        context 'media is created with an organization ancestor' do
          let(:organization) { Organization.create(title: ['organization'], team_id: []) }

          before do
            biological_specimen.organization_id = [organization.id]
            [biological_specimen].each(&:save)
          end

          context 'the organization does not have a linked team' do
            it 'does not call #add_access' do
              expect(subject).to receive(:add_team_access).with(env).and_call_original
              expect(subject).to receive(:add_organization_team_access).and_call_original
              expect(subject).not_to receive(:get_groups)
              subject.create(env)
            end
          end

          context 'the organization has a linked team' do
            let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: team_creator.ms_id) }
            let(:team_creator)          { User.create(email: 'creator@test.com', password: 'password') }
            let(:team_manager)          { User.create(email: 'manager@test.com', password: 'password') }
            let(:team_depositor)        { User.create(email: 'depositor@test.com', password: 'password') }
            let(:team_viewer)           { User.create(email: 'viewer@test.com', password: 'password') }

            before do
              organization.team_id = [team.id]
              organization.save

              team.create_collection_groups

              team.managers << team_manager
              team.depositors << team_depositor
              team.viewers << team_viewer
              team.user_groups.each(&:save)

              subject.create(env)
              work.save
              work.reload
            end

            it 'gives view access to the linked team members' do
              expect(work.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
              expect(team_manager.can?(:read, work)).to be(true)
              expect(team_depositor.can?(:read, work)).to be(true)
              expect(team_viewer.can?(:read, work)).to be(true)
            end
          end
        end
      end

      context 'media is created through the submission process for CHO' do
        let(:device)              { Device.create(title: ['device'], modality: ['Photogrammetry']) }
        let(:cho)                 { CulturalHeritageObject.create(title: ['private cho'], visibility: 'restricted', vouchered: ['Yes']) }
        let(:imaging_event)       { ImagingEvent.create(title: ['imaging_event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [cho.id]) }
        let(:processing_event)    { ProcessingEvent.create(title: ['processing event']) }

        before do
          imaging_event.ordered_members << processing_event
          [processing_event, imaging_event].each(&:save)

          env.attributes[:work_parents_attributes] = { '1' => { 'id' => processing_event.id, '_destroy' => 'false' } }
        end

        context 'media is associated with a CHO that does not belong to an organization' do
          it 'does not call #add_organization_team_access' do
            expect(subject).to receive(:add_team_access).with(env).and_call_original
            expect(subject).to receive(:find_parent).with(env).and_call_original
            expect(subject).not_to receive(:add_organization_team_access)
            subject.create(env)
          end
        end

        context 'media is created with an organization ancestor' do
          let(:organization) { Organization.create(title: ['organization'], team_id: []) }

          before do
            cho.organization_id = [organization.id]
            [cho].each(&:save)
          end

          context 'the organization does not have a linked team' do
            it 'does not call #add_access' do
              expect(subject).to receive(:add_team_access).with(env).and_call_original
              expect(subject).to receive(:add_organization_team_access).and_call_original
              expect(subject).not_to receive(:get_groups)
              subject.create(env)
            end
          end

          context 'the organization has a linked team' do
            let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: team_creator.ms_id) }
            let(:team_creator)          { User.create(email: 'creator@test.com', password: 'password') }
            let(:team_manager)          { User.create(email: 'manager@test.com', password: 'password') }
            let(:team_depositor)        { User.create(email: 'depositor@test.com', password: 'password') }
            let(:team_viewer)           { User.create(email: 'viewer@test.com', password: 'password') }

            before do
              organization.team_id = [team.id]
              organization.save

              team.create_collection_groups

              team.managers << team_manager
              team.depositors << team_depositor
              team.viewers << team_viewer
              team.user_groups.each(&:save)

              subject.create(env)
              work.save
              work.reload
            end

            it 'gives view access to the linked team members' do
              expect(work.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
              expect(team_manager.can?(:read, work)).to be(true)
              expect(team_depositor.can?(:read, work)).to be(true)
              expect(team_viewer.can?(:read, work)).to be(true)
            end
          end
        end
      end
    end
  end

  describe '#update' do
    let(:work) { Media.new(title: [ 'Previous title' ]) }
    let(:ability) { Ability.new(User.new) }
    let(:attrs) { {} }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    before do
      allow(subject).to receive(:generated_title) { 'Spiffy Generated Title' }
      allow(subject).to receive(:split_keywords) { ['one','two','three'] }
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    # When updating an embargo or lease, there won't be an env attribute for title
    context 'the user updates the work from the work edit page' do
      before do
        allow(env).to receive(:attributes).and_return({ "title" => ['title'] })
        allow(env).to receive(:attributes).and_return({ "keyword" => ['keyword'] })
      end
      it 'changes the title attribute' do
        expect { subject.update(env) }.to change{env.attributes['title']}.to([ 'Spiffy Generated Title' ])
      end
      it 'changes the keyword attribute' do
        expect { subject.update(env) }.to change{ env.attributes["keyword"]}.to([ 'one','two','three' ])
      end
    end
  end

  describe '#generated_title' do
    let(:user) { FactoryBot.build(:user) }
    let(:ability) { Ability.new(user) }
    let(:work) { Media.new }
    let(:device1) { Device.create(title: ['device1'], modality: ['MagneticResonanceImaging']) }
    let(:device2) { Device.create(title: ['device2'], modality: ['ScanningElectronMicroscopy']) }
    # let(:modality_attr) { [ device1.modality.first, device2.modality.first ] }
    let(:modality_labels) { [ 'MRI', 'SEM' ] }
    let(:part_attr) { [ 'leg', 'arm' ] }
    let(:work_parents_attributes) { { "0"=>{"id"=>"parentIE1", "_destroy"=>"false"} } }
    let(:work_parents_attributes_multiple) { { "0"=>{"id"=>"parentIE1", "_destroy"=>"false"}, "1"=>{"id"=>"parentIE2", "_destroy"=>"false"} } }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }

    before do
      ImagingEvent.create(title: ["Test ImagingEvent 1"], id: "parentIE1", ie_modality: device1.modality, device_id: [device1.id])
      ImagingEvent.create(title: ["Test ImagingEvent 2"], id: "parentIE2", ie_modality: device2.modality, device_id: [device2.id])
    end

    describe 'one modality' do
      describe 'no part' do
        let(:attrs) { { 'part' => [], 'work_parents_attributes' => [ work_parents_attributes.first ] } }
        let(:expected_title) { "Element Unspecified [#{modality_labels.first}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'work_parents_attributes' => [ work_parents_attributes.first ],
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'work_parents_attributes' => [ work_parents_attributes.first ],
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.first}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end

    describe 'more than one modality' do
      describe 'no part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => [] } }
        let(:expected_title) { "Element Unspecified [#{modality_labels.sort.join('/')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'one part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => [ part_attr.first ] } }
        let(:expected_title) { "#{part_attr.first.titleize} [#{modality_labels.sort.join('/')}]" }
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
      describe 'more than one part' do
        let(:attrs) { { 'work_parents_attributes' => work_parents_attributes_multiple,
                        'part' => part_attr } }
        let(:expected_title) { "#{part_attr.sort.join(', ').titleize} [#{modality_labels.sort.join('/')}]"}
        specify { expect(subject.generated_title(env)).to eq(expected_title)}
      end
    end
  end

  describe '#split_keywords' do
    let(:work) { Media.new }
    let(:ability) { Ability.new(User.new) }
    let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }
    context 'there is no tags attribute' do
      let(:attrs) { {} }
      it 'returns nil' do
        expect(subject.send(:split_keywords, env)).to be(nil)
      end
    end
    context 'there are tags' do
      let(:attrs) { {'tags' => 'one,two,three'} }
      it 'splits a string on the commas' do
        expect(subject.send(:split_keywords, env)).to eq(['one','two','three'])
      end
    end
  end
end
