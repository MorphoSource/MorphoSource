require 'rails_helper'

RSpec.describe 'submissions/organization' do
  let(:ability) { double Ability }

  before do
		@organization_form = Hyrax::WorkFormService.build(Organization.new, ability, self)
  end

  describe 'organization_select partial' do
    let(:partial_content) { 'organization_select partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_organization_select.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'organization_create partial' do
    let(:partial_content) { 'organization_create partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_organization_create.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

end
