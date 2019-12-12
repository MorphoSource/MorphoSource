require 'rails_helper'

RSpec.describe 'submissions/_parent_media_form' do
  describe 'parent media form partial' do
    let(:partial_content) { 'parent media form content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_parent_media_form.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
end
