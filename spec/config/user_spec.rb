# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Hyrax::User do
  let(:user) { User.create(email: 'email@email.com', password: 'password') }

  describe '#name' do
    context 'user has a display name' do
      before do
        user.display_name = 'Donald Duck'
      end
      it 'returns the display name' do
        expect(user.name).to eq(user.display_name)
      end
    end
    context 'user display_name is nil' do
      before do
        user.display_name = nil
      end
      it 'returns the user ms_id boilerplate' do
        expect(user.name).to eq("User #{user.ms_id.to_s.upcase}")
      end
    end
    context 'user display_name is an empty string' do
      before do
        user.display_name = ''
      end
      it 'returns the user ms_id boilerplate' do
        expect(user.name).to eq("User #{user.ms_id.to_s.upcase}")
      end
    end
  end
end
