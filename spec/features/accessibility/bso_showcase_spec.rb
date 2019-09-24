require "rails_helper"

RSpec.feature "BSO showcase Accessibility check", :accessibility => true, :type => :feature, :driver => :firefox_headless do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

	before do
   	@test_user = User.create(id: 1, email: "example@email.com", password: "password") 
   	# todo: create related works later (media, institution, device, taxonomy) for a complete test
 		# Media.create(id: "media123", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['open'])
	 	bso1 = BiologicalSpecimen.create(
	 		id: "abc123", 
	 		title: ["test biological specimen"], 
	 		vouchered: ['Yes'], 
	 		institution_code: ['abc123'], 
	 		collection_code: ['xyz'], 
	 		catalog_number: ['xyz'],
	 		visibility: public
	 	) 

	end

  scenario "page should be accessible" do
    # todo: create a method to login later , e.g. login_as(@test_user)
  	visit "/users/sign_in"	
    #expect(page).to have_content 'Log in'
		fill_in 'user_email', :with => @test_user.email
		fill_in 'user_password', :with => @test_user.password
		click_button("Log in")

		visit "/concern/biological_specimens/#{BiologicalSpecimen.last.id}"
    expect(page).to have_content 'Biological Specimen Object', wait: 7
    expect(page).to be_accessible
  end


end
