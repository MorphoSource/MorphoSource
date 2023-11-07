require 'rails_helper'

include ActionDispatch::TestProcess

RSpec.describe RegistrationsController, :type => :controller  do

  let(:params) { {user: {
    email: "user@test.com",
    password: 'password',
    display_name: "Test User",
    first_name: "first",
    middle_name: "middle",
    last_name: "last",
    affiliation: "",
    address: "Test Address",
    city: "city",
    country: "US",
    state: "NC",
    demographics: ["demo1","demo2",""],
    intent: ["intent1","intent2",""],
    orcid: "https://orcid.org/0000-0000-0000-0000",
    twitter_handle: "@TestTest",
    facebook_handle: "test.test",
    website: "morphosource.org",
    profile_type: 'Faculty or Staff (University, Museum, and/or Library)',
    typical_usage: "usage",
    academic_institution_or_school: "school",
    department: "dept",
    academic_field: "acad field",
    academic_subfield: "acad subfield",
    mentor_or_advisor: "",
    instructor: "",
    terms_read: true
  }}}

  let(:params2) { {user: {
    email: "user@test.com",
    password: 'password',
    display_name: "Test User",
    first_name: "first",
    middle_name: "middle",
    last_name: "last",
    affiliation: "",
    address: "Test Address",
    city: "city",
    country: "US",
    state: "NC",
    demographics: ["demo1","demo2",""],
    intent: ["intent1","intent2",""],
    orcid: "https://orcid.org/0000-0000-0000-0000",
    twitter_handle: "@TestTest",
    facebook_handle: "test.test",
    website: "morphosource.org",
    profile_type: '',
    typical_usage: "usage",
    academic_institution_or_school: "school",
    department: "dept",
    academic_field: "acad field",
    academic_subfield: "acad subfield",
    mentor_or_advisor: "",
    instructor: "",
    terms_read: true
  }}}

  let(:params3) { {user: {
    email: "user@test.com",
    password: 'password',
    display_name: "Test User",
    first_name: "first",
    middle_name: "middle",
    last_name: "last",
    affiliation: "",
    address: "Test Address",
    city: "city",
    country: "US",
    state: "NC",
    demographics: ["demo1","demo2",""],
    intent: ["intent1","intent2",""],
    orcid: "https://orcid.org/0000-0000-0000-0000",
    twitter_handle: "@TestTest",
    facebook_handle: "test.test",
    website: "morphosource.org",
    profile_type: 'Artist',
    typical_usage: "usage",
    academic_institution_or_school: "school",
    department: "dept",
    academic_field: "acad field",
    academic_subfield: "acad subfield",
    mentor_or_advisor: "",
    instructor: "",
    terms_read: true
  }}}

  let(:params4) { {user: {
    email: "user@test.com",
    password: 'password',
    display_name: "Test User",
    first_name: "",
    middle_name: "middle",
    last_name: "",
    affiliation: "",
    address: "Test Address",
    city: "city",
    country: "US",
    state: "NC",
    demographics: ["demo1","demo2",""],
    intent: ["intent1","intent2",""],
    orcid: "https://orcid.org/0000-0000-0000-0000",
    twitter_handle: "@TestTest",
    facebook_handle: "test.test",
    website: "morphosource.org",
    profile_type: 'Faculty or Staff (University, Museum, and/or Library)',
    typical_usage: "usage",
    academic_institution_or_school: "school",
    department: "dept",
    academic_field: "acad field",
    academic_subfield: "acad subfield",
    mentor_or_advisor: "",
    instructor: "",
    terms_read: true
  }}}

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'does not create a new user without a profile type' do
    expect{
      process :create, method: :post, params: params2
    }.to change{User.count}.by(0)
  end

  it 'does not create a new user without metadata fields not associated with the profile type' do
    expect{
      process :create, method: :post, params: params3
    }.to change{User.count}.by(0)
  end

  it 'does not create a new user with empty required fields' do
    expect{
      process :create, method: :post, params: params4
    }.to change{User.count}.by(0)
  end

  it 'creates a new user with morphosource attributes, and removes empty strings from multi-value fields' do
    expect{
      process :create, method: :post, params: params
    }.to change{User.count}.by(1)
    user = User.last
    expect(user.email).to eq("user@test.com")
    expect(user.facebook_handle).to eq("test.test")
    expect(user.twitter_handle).to eq("@TestTest")
    expect(user.display_name).to eq("Test User")
    expect(user.first_name).to eq("first")
    expect(user.middle_name).to eq("middle")
    expect(user.last_name).to eq("last")
    expect(user.address).to eq("Test Address")
    expect(user.city).to eq("city")
    expect(user.state).to eq("NC")
    expect(user.country).to eq("US")
    expect(user.website).to eq("morphosource.org")
    expect(user.orcid).to eq("https://orcid.org/0000-0000-0000-0000")
    expect(user.terms_read).to eq(true)
    expect(user.demographics).to match_array(["demo1", "demo2"])
    expect(user.intent).to match_array(["intent1", "intent2"])
    expect(user.profile_type).to eq("Faculty or Staff (University, Museum, and/or Library)")
    expect(user.typical_usage).to eq("usage")
    expect(user.academic_institution_or_school).to eq("school")
    expect(user.department).to eq("dept")
    expect(user.academic_field).to eq("acad field")
    expect(user.academic_subfield).to eq("acad subfield")
  end

end
