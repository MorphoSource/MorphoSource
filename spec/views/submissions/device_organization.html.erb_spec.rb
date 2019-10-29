require 'rails_helper'

RSpec.describe 'submissions/device_organization' do
  let(:ability) { double Ability }
  let(:new_organization_title) { ['XXYYZZ'] }

  before do
    assign(:submission, Submission.new)
		@organization_form = Hyrax::WorkFormService.build(Organization.new, ability, self)
	  session[:submission_organization_create_params] = ActionController::Parameters.new(title: new_organization_title)
	  render
  end

  describe 'device_organization_select partial' do
    it 'manually adds the new Organization to the select dropdown list' do
      expect(rendered).to match(/#{new_organization_title}/)
    end
  end

  describe 'device_organization_create partial' do
    let(:partial_content) { 'device_organization_create partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_device_organization_create.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

end
