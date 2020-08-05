require 'rails_helper'

RSpec.describe "hyrax/users/index.json.jbuilder" do

  let(:user1)         { User.create(email: 'apple@email.com', password: 'password') }
  let(:user2)         { User.create(email: 'banana@email.com', password: 'password') }
  let(:user3)         { User.create(email: 'orange@email.com', password: 'password') }
  let(:users)         { [user1, user2, user3] }

  before do
    assign(:users, users)
    render
  end

  it "lists users by ms_id and email" do
    json = JSON.parse(rendered)
    expect(json['users']).to match_array([
      { 'id' => user1.ms_id, 'text' => user1.email },
      { 'id' => user2.ms_id, 'text' => user2.email },
      { 'id' => user3.ms_id, 'text' => user3.email }
      ])
  end
end
