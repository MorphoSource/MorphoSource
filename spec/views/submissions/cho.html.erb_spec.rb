require 'rails_helper'

RSpec.describe 'submissions/cho' do
  describe 'cho search partial' do
    let(:partial_content) { 'cho Search partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_cho_search.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'cho search results partial' do
    let(:partial_content) { 'cho Search Results partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_cho_search_results.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
end
