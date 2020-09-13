# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Works::Base do
  let(:organization)    { Organization.create(title: ['organization title']) }
  let(:specimen1)       { BiologicalSpecimen.create(title: ['title'], vouchered: [true]) }
  let(:specimen2)       { BiologicalSpecimen.create(title: ['title'], vouchered: [false]) }
  let(:media1)          { Media.create(title: ['title']) }
  let(:media2)          { Media.create(title: ['title']) }
  let(:media3)          { Media.create(title: ['title']) }
  let(:file_set1)       { FileSet.create }
  let(:file_set2)       { FileSet.create }
  let(:file_set3)       { FileSet.create }
  let(:imagingEvent)    { ImagingEvent.create(title: ['title']) }
  let(:imagingEvent2)   { ImagingEvent.create(title: ['title']) }
  let(:processingEvent) { ProcessingEvent.create(title: ['title']) }
  let(:works)           { [organization, specimen1, specimen2, media1, media2, media3, imagingEvent, imagingEvent2, processingEvent, file_set1, file_set2, file_set3] }

  describe '#descendants' do
    let(:org_desc)      { works - [organization] }
    let(:spec1_desc)    { [imagingEvent, media1, file_set1, processingEvent, media2, file_set2] }
    let(:spec2_desc)    { [imagingEvent2, media3, file_set3] }

    before do
      organization.ordered_members << specimen1 << specimen2
      specimen1.ordered_members << imagingEvent
      imagingEvent.ordered_members << media1
      media1.ordered_members << processingEvent << file_set1
      processingEvent.ordered_members << media2
      media2.ordered_members << file_set2
      specimen2.ordered_members << imagingEvent2
      imagingEvent2.ordered_members << media3
      media3.ordered_members << file_set3
      works.each(&:save)
    end

    it 'finds all children (works and filesets) of a work' do
      expect(organization.descendants).to match_array(org_desc)
      expect(specimen1.descendants).to match_array(spec1_desc)
      expect(specimen2.descendants).to match_array(spec2_desc)
    end
  end

  describe 'user_with_ownership' do
    subject         { media1.user_with_ownership }
    let(:owner)     { User.create(email: 'owner@email.com', password: 'password') }
    let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
    before do
      media1.depositor = depositor.ms_id
    end
    context 'work has an owner' do
      before do
        media1.owner = owner.ms_id
      end
      it 'returns the owner' do
        expect(subject).to eq(owner.ms_id)
      end
    end
    context 'work does not have an owner' do
      context 'ms_id does not exist' do
        before do
          media1.owner = 'notanmsid'
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
      context 'ms_id is nil' do
        before do
          media1.owner = nil
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
      context 'ms_id is empty' do
        before do
          media1.owner = ''
        end
        it 'returns the depositor' do
          expect(subject).to eq(depositor.ms_id)
        end
      end
    end
  end
end
