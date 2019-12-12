require 'rails_helper'

RSpec.describe 'submissions/new' do
  describe 'raw derived media partial' do
    let(:partial_content) { 'Raw Derived Media partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_raw_derived_media.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'biospec or cho partial' do
    let(:partial_content) { 'Biological Specimen or Cultural Heritage Object partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_physical_object.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'biospec partial' do
    let(:partial_content) { 'BioSpec partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_biospec_search.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'CHO partial' do
    let(:partial_content) { 'CHO partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_cho_search.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

  describe 'parent media in MS partial' do
    let(:partial_content) { 'parent media in MS content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_parents_in_ms.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'parent media not in MS partial' do
    let(:partial_content) { 'parent media not in MS content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_parents_not_in_ms.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

end
