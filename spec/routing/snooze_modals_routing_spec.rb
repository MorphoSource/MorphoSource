require 'rails_helper'

RSpec.describe 'snooze modals routing', type: :routing do
  let(:snooze_controller) { 'morphosource/snooze_modals' }

  {
    'modal' => Morphosource::Forms::Admin::Modal,
    'download_modal' => Morphosource::Forms::Admin::Modals::DownloadModal
  }.each do |modal, form_class|
    context "#{modal} snoozing" do
      it 'has the necessary routes' do
        %w[snooze_hour snooze_day snooze_week].each do |action|
          expect(:post => "/#{modal}/#{action}").to route_to(controller: snooze_controller, action: action, modal: modal)
        end
      end

      it 'has named route helpers that match the form paths' do
        form = form_class.new
        %w[snooze_hour snooze_day snooze_week].each do |action|
          path = "/#{modal}/#{action}"
          expect(send("#{modal}_#{action}_path")).to eq(path)
          expect(form.public_send("#{action}_path")).to eq(path)
        end
      end
    end
  end
end
