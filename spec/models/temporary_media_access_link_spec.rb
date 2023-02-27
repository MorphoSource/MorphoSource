require 'rails_helper'

RSpec.describe TemporaryMediaAccessLink do
  it { should belong_to(:user) }

  describe "instance" do
    let(:user)  { create(:confirmed_user) }
    let(:media) { create(:media, depositor: user.ms_id ) }

    it "is valid with valid attributes" do
      subject.user = user
      subject.media_id = media.id
      subject.expires_at = Time.zone.now + 1.month
      expect(subject).to be_valid
    end

    it "saves successfully and generates a token on saving" do
      subject.user = user
      subject.media_id = media.id
      subject.expires_at = Time.zone.now + 1.month
      subject.save!
      expect(subject.token.present?).to be true
    end
  end
end