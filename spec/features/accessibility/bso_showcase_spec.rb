require "rails_helper"

RSpec.feature "Showcase pages accessibility check", :skiptravis => true, :accessibility => true, :type => :feature, :driver => :firefox_headless do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

  before do
   	@test_user = User.create(id: 1, email: "example@email.com", password: "password") 
    # PO > IE > media 
    # or
    # PO > IE > PE > media (media with absentee parent) 
    
    inst = Organization.create({
        id: 'inst123',
        title: ['organization 1'],
        institution_code: ['inst123'] ,
        visibility: public
    })

 	bso = BiologicalSpecimen.create(
 		id: "bso123", 
 		title: ["test biological specimen"], 
 		vouchered: ['Yes'], 
 		institution_code: ['inst123'], 
 		collection_code: ['xyz'], 
 		catalog_number: ['xyz'],
 		visibility: public,
        organization: [inst.id]
 	) 

    ie = ImagingEvent.create(
        title: ["Test ImagingEvent"], 
        id: "ie123", 
        ie_modality: ['MicroNanoXRayComputedTomography'],
        visibility: public,
        physical_object_id: [bso.id]
    )

    pe = ProcessingEvent.create(
        title: ["Test ProcessingEvent"], 
        id: "pe123",
        visibility: public
    )
    
    media = Media.create({
        id: 'media123',
        title: ['media 1'],
        media_type: ['image'],
        visibility: public
    })

    ie.members = [pe]
    ie.save!
    pe.members = [media]
    pe.save!

    # todo: create a method to login later , e.g. login_as(@test_user)
    visit "/users/sign_in"  
    #expect(page).to have_content 'Log in'
    fill_in 'user_email', :with => @test_user.email
    fill_in 'user_password', :with => @test_user.password
    click_button("Log in")

  end

  scenario "BSO show page should be accessible" do
	visit "/concern/biological_specimens/#{BiologicalSpecimen.last.id}"
    expect(page).to have_content 'Biological Specimen Object', wait: 7
    expect(page).to be_accessible
  end

  scenario "Media show page should be accessible" do
    visit "/concern/media/#{Media.last.id}"
    expect(page).to have_content 'Media', wait: 7
    expect(page).to be_accessible
  end

end
