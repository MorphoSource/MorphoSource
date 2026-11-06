require 'rails_helper'

RSpec.describe Morphosource::AppearanceHelper, type: :helper do
  {
    sitewide_modal?: 'hide_donation_modal',
    download_modal?: 'hide_download_modal'
  }.each do |method, cookie_key|
    describe "##{method}" do
      before do
        allow(helper).to receive(:lucky_day?).and_return(true)
      end

      context "when the #{cookie_key} cookie is set" do
        before { helper.request.cookies[cookie_key] = 'true' }

        it 'returns false' do
          expect(helper.public_send(method)).to be(false)
        end
      end

      context "when the #{cookie_key} cookie is not set" do
        it 'defers to the frequency setting' do
          expect(helper.public_send(method)).to be(true)
        end
      end
    end
  end

  describe '#download_modal? frequency' do
    let(:form) { instance_double(Morphosource::Forms::Admin::Modals::DownloadModal, modal_frequency: frequency) }

    before do
      allow(Morphosource::Forms::Admin::Modals::DownloadModal).to receive(:new).and_return(form)
    end

    context 'when the download modal frequency is 100%' do
      let(:frequency) { '1.0' }

      it 'shows the modal' do
        expect(helper.download_modal?).to be(true)
      end
    end

    context 'when the download modal frequency is never' do
      let(:frequency) { '0' }

      it 'does not show the modal' do
        expect(helper.download_modal?).to be(false)
      end
    end
  end
end
