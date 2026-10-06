require 'rails_helper'

RSpec.describe 'snooze modals routing', type: :routing do
  let(:snooze_controller) { 'morphosource/snooze_modals' }

  %w[modal download_modal].each do |modal|
    context "#{modal} snoozing" do
      it 'has the necessary routes' do
        %w[snooze_hour snooze_day snooze_week].each do |action|
          expect(:post => "/#{modal}/#{action}").to route_to(controller: snooze_controller, action: action, modal: modal)
        end
      end
    end
  end
end
