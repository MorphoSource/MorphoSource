require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::TaxonomyHelper, type: :helper do

  let(:taxonomy)  { Taxonomy.new(depositor: "msid123") }

  before do
    allow(User).to receive(:find_by_user_key).with("msid123").and_return(user)
  end

  describe 'contributing_user_link' do

    context 'the user has a display name' do
      let(:user)      { User.new( id: 1, email: "example@email.com", display_name: "D. Name", ms_id: "msid123") }
      let(:content) do
        %(<a class="contributing-user" href="/users/msid123">D. Name: </a>)
      end

      it 'links the display name to the user profile page' do
        expect(contributing_user_link(taxonomy)).to be_equivalent_to(content)
      end
    end

    context 'the user does not have a display name' do
      let(:user)      { User.new( id: 2, email: "example@email.com", display_name: nil, ms_id: "msid123") }
      let(:content) do
        %(<a class="contributing-user" href="/users/msid123">example@email.com: </a>)
      end

      it 'links the user email to the user profile page' do
        expect(contributing_user_link(taxonomy)).to be_equivalent_to(content)
      end
    end



  end

end
