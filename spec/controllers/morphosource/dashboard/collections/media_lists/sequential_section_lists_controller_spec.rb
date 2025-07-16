# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaLists::SequentialSectionListsController, type: :controller do
  include SingleValuedForm

  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                               { User.create(email: 'depositor@email.com', password: 'password') }
  let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential section list'], collection_type_gid: sequential_section_list_collection_type.to_global_id, depositor: depositor.ms_id) }

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Sequential Section List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(SequentialSectionList) }
  end
end
