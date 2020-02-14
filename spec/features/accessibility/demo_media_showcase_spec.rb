require "rails_helper"

RSpec.feature "MS-demo Accessibility check", :accessibility => true, :type => :feature, :driver => :firefox_headless do

  before do
    visit "https://morphosource-demo.lib.duke.edu/users/sign_in?locale=en"  
    #click_link('Login')
    expect(page).to have_content 'Log in'
    fill_in 'user_email', :with => Morphosource.ms_test_usr
    fill_in 'user_password', :with => Morphosource.ms_test_pw
    click_button("Log in")
    expect(page).to have_content 'a11y' # make sure user is logged in
    visit "https://morphosource-demo.lib.duke.edu/catalog?f%5Bhuman_readable_type_sim%5D%5B%5D=Media&locale=en&q=&search_field=all_fields"  # search result filtered by Media
  end

  # testing a few links on the search result

  scenario "Media page 1 should be accessible" do
    page.all(:css, 'a[href*="concern/media"]').first.click 
    expect(page).to have_content 'FILE OBJECT DETAILS', wait: 10
    expect(page).to be_accessible
  end

  scenario "Media page 2 should be accessible" do
    page.all(:css, 'a[href*="concern/media"]')[1].click 
    expect(page).to have_content 'FILE OBJECT DETAILS', wait: 10
    expect(page).to be_accessible
  end

  scenario "Media page 3 should be accessible" do
    page.all(:css, 'a[href*="concern/media"]')[2].click 
    expect(page).to have_content 'FILE OBJECT DETAILS', wait: 10
    expect(page).to be_accessible
  end

end
