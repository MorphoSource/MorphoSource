require "rails_helper"

RSpec.feature "BSO showcase Accessibility check", :accessibility => true, :type => :feature, :driver => :firefox_headless do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

	before do
   	@test_user = User.create(id: 1, email: "example@email.com", password: "password") 
    # PO > IE > media 
    # or
    # PO > IE > PE > media (media with absentee parent) 
    media = Media.create({
        id: 'media123',
        title: ['media 1']
    })

    pe = ProcessingEvent.create(
    	title: ["Test ProcessingEvent"], 
    	id: "pe123"
  	)
    pe.members = [media]
    pe.save!

    ie = ImagingEvent.create(
    	title: ["Test ImagingEvent"], 
    	id: "ie123", 
    	ie_modality: ['MedicalXRayComputedTomography']
  	)
    ie.members = [pe]
    ie.save!

	 	bso = BiologicalSpecimen.create(
	 		id: "bso123", 
	 		title: ["test biological specimen"], 
	 		vouchered: ['Yes'], 
	 		institution_code: ['inst123'], 
	 		collection_code: ['xyz'], 
	 		catalog_number: ['xyz'],
	 		visibility: public
	 	) 
    bso.members = [ie]
    bso.save!

    inst = Organization.create({
        id: 'inst123',
        title: ['organization 1'],
		 		institution_code: ['inst123'] 
    })
    inst.members = [bso]
    inst.save!

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
