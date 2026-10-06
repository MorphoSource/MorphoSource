require 'rails_helper'

RSpec.describe Morphosource::SnoozeModalsController, type: :controller do
  { 'modal' => :hide_donation_modal, 'download_modal' => :hide_download_modal }.each do |modal, cookie_key|
    context "with the #{modal} modal" do
      %i[snooze_hour snooze_day snooze_week].each do |action|
        describe "##{action}" do
          it "sets the #{cookie_key} cookie without requiring sign in" do
            post action, params: { modal: modal }

            expect(response).to have_http_status(:ok)
            expect(cookies[cookie_key]).to be(true)
          end
        end
      end
    end
  end
end
