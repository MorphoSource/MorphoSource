# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Action::CreateWorkService do
  let(:user) { User.create(email: 'create_svc@test.com', password: 'password') }
  let(:form) { double('form', validate: true, errors: double(messages: {})) }

  before do
    allow(Hyrax::FormFactory).to receive_message_chain(:new, :build).and_return(form)
  end

  describe 'ImagingEventResource' do
    subject do
      described_class.new(
        model: ImagingEventResource,
        params: { imaging_event_resource: { title: ['Test IE'] } },
        user: user
      )
    end

    describe '#transaction_name' do
      it 'uses imaging_event_change_set.create_work' do
        expect(subject.send(:transaction_name)).to eq('imaging_event_change_set.create_work')
      end
    end

    describe '#step_args' do
      it 'includes set_user_as_depositor with the user' do
        expect(subject.send(:step_args)['change_set.set_user_as_depositor']).to eq({ user: user })
      end

      it 'includes save_acl' do
        expect(subject.send(:step_args)).to have_key('work_resource.save_acl')
      end
    end

    describe '#call' do
      let(:transaction) { double('transaction') }

      before do
        allow(Hyrax::Transactions::Container).to receive(:[])
          .with('imaging_event_change_set.create_work')
          .and_return(transaction)
        allow(transaction).to receive(:with_step_args).and_return(transaction)
        allow(transaction).to receive(:call).and_return(Dry::Monads::Success(double('work')))
      end

      it 'dispatches to imaging_event_change_set.create_work' do
        expect(transaction).to receive(:call).with(form)
        subject.call
      end

      context 'when form validation fails' do
        before { allow(form).to receive(:validate).and_return(false) }

        it 'raises an error' do
          expect { subject.call }.to raise_error(/Error creating ImagingEventResource/)
        end
      end
    end
  end

  describe 'attributes_key' do
    it 'is inferred from the model name' do
      svc = described_class.new(
        model: ImagingEventResource,
        params: { imaging_event_resource: {} },
        user: user
      )
      expect(svc.send(:attributes_key)).to eq(:imaging_event_resource)
    end

    it 'uses work_attributes_key when provided' do
      svc = described_class.new(
        model: ImagingEventResource,
        params: { custom_key: {} },
        user: user,
        work_attributes_key: :custom_key
      )
      expect(svc.send(:attributes_key)).to eq(:custom_key)
    end
  end

  describe 'with an unpermitted model' do
    subject { described_class.new(model: Media, params: {}, user: user) }

    it 'raises on transaction_name' do
      expect { subject.send(:transaction_name) }.to raise_error(/Unpermitted work type Media/)
    end

    it 'raises on step_args' do
      expect { subject.send(:step_args) }.to raise_error(/Unpermitted work type Media/)
    end
  end
end
