require 'rails_helper'

RSpec.describe 'submissions/_parents_in_ms' do
  describe 'parent media select partial' do
    let(:partial_content) { 'parent media select content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_parent_media_select.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
end
