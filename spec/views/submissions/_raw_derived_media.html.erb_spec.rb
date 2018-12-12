require 'rails_helper'

RSpec.describe 'submissions/_raw_derived_media', type: :view do
  let(:submission) { Submission.new }
  let(:form_template) do
    %(
      <%= simple_form_for @submission do |f| %>
        <%= render 'submissions/raw_derived_media', f: f %>
      <% end %>
    )
  end
  let(:page) do
    assign(:submission, submission)
    render inline: form_template
    Capybara::Node::Simple.new(rendered)
  end
  it 'displays the raw/derived media question' do
    expect(page).to have_content(I18n.t('simple_form.labels.submission.raw_or_derived_media'))
    expect(page).to have_unchecked_field(Submission::MEDIA_RAW)
    expect(page).to have_unchecked_field(Submission::MEDIA_DERIVED)
  end
end
