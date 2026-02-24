require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::DownloadsController, :type => :controller do

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['date_downloaded asc',
       'date_downloaded desc',
       'download_usage asc',
       'download_usage desc',
       'download_usage_list asc',
       'download_usage_list desc',
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