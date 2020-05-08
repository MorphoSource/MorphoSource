require 'rails_helper'

RSpec.describe Role do
  let(:role)  { Role.new(name: 'new role') }

  describe '#to_s' do
    it 'returns the name' do
      expect(role.to_s).to eq(role.name)
    end
  end
end
