require 'rails_helper'

RSpec.describe 'submissions/_physical_object', type: :view do
  let(:submission) { Submission.new }
  let(:form_template) do
    %(
      <%= simple_form_for @submission do |f| %>
        <%= render 'submissions/physical_object', f: f %>
      <% end %>
    )
  end
  let(:page) do
    assign(:submission, submission)
    render inline: form_template
    Capybara::Node::Simple.new(rendered)
  end
  it 'displays the biological specimen or cultural heritage object question' do
    expect(page).to have_content(I18n.t('simple_form.labels.submission.biospec_or_cho'))
    expect(page).to have_unchecked_field(Submission::PHYSICAL_OBJECT_BIOSPEC[:label])
    expect(page).to have_unchecked_field(Submission::PHYSICAL_OBJECT_CHO[:label])
  end
end
