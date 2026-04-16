# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::MintArkListener do
  include ActiveJob::TestHelper

  subject(:listener) { described_class.new }

  before do
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'enqueues mint job on deposit and indexes ark_tesim after job runs' do
    user = FactoryBot.create(:user)
    device = FactoryBot.valkyrie_create(
      :device_resource,
      with_index: false,
      title: ['Device With Ark'],
      creator: [user.ms_id],
      depositor: user.ms_id,
      modality: ['MicroCT']
    )

    allow_any_instance_of(DeviceResource).to receive(:mint_ark) do |resource|
      resource.ark = ['ark:/99999/fk4/integration']
      resource
    end

    event = instance_double('Dry::Event', payload: { object: device })

    expect do
      listener.on_object_deposited(event)
    end.to have_enqueued_job(MintWorkArkJob).with(device.id.to_s)

    perform_enqueued_jobs

    solr_doc = SolrDocument.find(device.id.to_s)
    expect(solr_doc['ark_tesim']).to include('ark:/99999/fk4/integration')
  end
end
