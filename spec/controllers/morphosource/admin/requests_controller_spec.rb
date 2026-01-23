require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::RequestsController, :type => :controller do

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['date_approved asc',
       'date_approved desc',
       'date_canceled asc',
       'date_canceled desc',
       'date_cleared asc',
       'date_cleared desc',
       'date_denied asc',
       'date_denied desc',
       'date_downloaded asc',
       'date_downloaded desc',
       'date_expired asc',
       'date_expired desc',
       'date_requested asc',
       'date_requested desc',
       'reviewers asc',
       'reviewers desc',
       'use asc',
       'use desc',
       'users.display_name asc',
       'users.display_name desc',
       'work_id asc',
       'work_id desc']
    end

    it 'includes custom sort parameters' do
      expect(subject.allowed_sort_parameters).to match_array(allowed_sort_params)
    end
  end
end