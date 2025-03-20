require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer do

  describe "#user_link" do
    subject         { Nokogiri::HTML(renderer.render) }

    let(:field)     { :data_managed_by }
    let(:user1)     { User.create(ms_id: 'user1', display_name: 'user1 display name', email: 'user1@email.com') }
    let(:user2)     { User.create(ms_id: 'user2', email: 'user2@email.com') }

    let(:content1)   { "<div class='row'><div class='col-6 showcase-label'>Data managed by</div><div class='col-6 showcase-value '><a href=#{'/users/' + user.ms_id}>#{user.name}</a></div></div>" }
    let(:content2)   { "<div class='row'><div class='col-6 showcase-label'>Data managed by</div><div class='col-6 showcase-value '><a href=#{'/users/' + user.ms_id}>#{user.email}</a></div></div>" }

    let(:renderer)  { described_class.new(field, user.ms_id) }
    let(:expected1)  { Nokogiri::HTML(content1) }
    let(:expected2)  { Nokogiri::HTML(content2) }

    before do
      allow(User).to receive(:find_by_user_key).with(user1.ms_id).and_return(user1)
      allow(User).to receive(:find_by_user_key).with(user2.ms_id).and_return(user2)
    end

    context 'user has a display name' do
      let(:user) { user1 }

      it 'displays the display name' do
        expect(subject).to be_equivalent_to(expected1)
      end
    end

    context 'user does not have a display name' do
      let(:user) { user2 }

      it 'displays the ms_id' do
        expect(subject).to be_equivalent_to(expected2)
      end
    end
  end
end