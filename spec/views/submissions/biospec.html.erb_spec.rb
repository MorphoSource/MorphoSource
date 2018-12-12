require 'rails_helper'

RSpec.describe 'submissions/biospec' do
  describe 'biospec search partial' do
    let(:partial_content) { 'BioSpec Search partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_biospec_search.html.erb' => partial_content
      stub_template 'submissions/_biospec_create.html.erb' => 'foo'
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'biospec search results partial' do
    let(:partial_content) { 'BioSpec Search Results partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_biospec_search_results.html.erb' => partial_content
      stub_template 'submissions/_biospec_create.html.erb' => 'foo'
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'biospec create partial' do
    let(:partial_content) { 'BioSpec Create partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_biospec_create.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
end
