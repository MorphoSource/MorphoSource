require 'rails_helper'

RSpec.describe Morphosource::ACL do

  it 'has a download property' do
    expect(Morphosource::ACL.Download.to_h).to eq({:scheme=>"http", :authority=>"morphosource.org", :userinfo=>nil, :user=>nil, :password=>nil, :host=>"morphosource.org", :port=>nil, :path=>"/ns/auth/acl", :query=>nil, :fragment=>"Download"})
  end

end
