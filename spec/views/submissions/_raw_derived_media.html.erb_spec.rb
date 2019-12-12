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
  it 'displays the initial information question' do
    expect(page).to have_content(I18n.t('simple_form.labels.submission.cb_derived'))
    expect(page).to have_content(I18n.t('simple_form.labels.submission.cb_child_media_in_ms'))
    expect(page).to have_unchecked_field('cb_derived')
    expect(page).to have_unchecked_field('cb_child_media_in_ms')
  end
end
