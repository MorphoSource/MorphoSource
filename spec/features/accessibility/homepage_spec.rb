require "rails_helper"

RSpec.feature "Accessibility check on homepage", :skiptravis => true, :accessibility => true, :type => :feature, :driver => :firefox_headless do

  before do
    visit "/"
  end

  scenario "homepage should be accessible" do
    expect(page).to be_accessible
  end


end
