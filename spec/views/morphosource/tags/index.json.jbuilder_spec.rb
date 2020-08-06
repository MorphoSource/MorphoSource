require 'rails_helper'

RSpec.describe "morphosource/tags/index.json.jbuilder" do

  let(:tags) { ["apple", 33, "banana", 33, "cherry", 33] }

  before do
    assign(:tags, tags)
    render
  end

  it 'lists tags' do
    json = JSON.parse(rendered)
    expect(json['tags']).to match_array([
      { 'id' => 'apple', 'text' => 'apple' },
      { 'id' => 'banana', 'text' => 'banana' },
      { 'id' => 'cherry', 'text' => 'cherry' }
      ])
  end

end
