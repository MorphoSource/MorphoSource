require 'rails_helper'

RSpec.describe 'shared/collections/_managed_by.html.erb', type: :view do
  def render_with(manager_links)
    render partial: 'shared/collections/managed_by', locals: { manager_links: manager_links }
  end

  it 'renders the manager links behind a separator' do
    render_with('<a href="/users/abc123">Ada Lovelace</a>'.html_safe)

    expect(rendered).to include('· Managed by: <a href="/users/abc123">Ada Lovelace</a>')
  end

  it 'renders nothing when there are no managers to show' do
    render_with(''.html_safe)

    expect(rendered.strip).to eq('')
  end
end
