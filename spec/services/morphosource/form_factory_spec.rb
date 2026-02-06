require 'rails_helper'

RSpec.describe Morphosource::FormFactory do
  describe '#build' do
    let(:model) { instance_double('Model') }
    let(:ability) { instance_double('Ability') }
    let(:controller) { instance_double('Controller') }

    it 'sets controller when the form supports it' do
      form = double('Form')
      allow(form).to receive(:controller=)
      allow_any_instance_of(Hyrax::FormFactory).to receive(:build).and_return(form)

      result = described_class.new.build(model, ability, controller)

      expect(result).to eq(form)
    end

    it 'does not raise when the form does not support controller=' do
      form = double('Form')
      allow_any_instance_of(Hyrax::FormFactory).to receive(:build).and_return(form)

      expect { described_class.new.build(model, ability, controller) }.not_to raise_error
    end
  end
end
