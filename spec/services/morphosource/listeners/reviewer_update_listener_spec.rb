# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::ReviewerUpdateListener do
  subject(:listener) { described_class.new }

  let(:media_event)        { instance_double('Dry::Events::Event', payload: { media_id: 'media-1' }) }
  let(:organization_event) { instance_double('Dry::Events::Event', payload: { organization_id: 'org-1' }) }

  # Both handlers are inert until the jobs they will enqueue exist.
  before { ActiveJob::Base.queue_adapter = :test }

  describe '#on_media_reviewers_updated' do
    it 'accepts the event without raising' do
      expect { listener.on_media_reviewers_updated(media_event) }.not_to raise_error
    end

    it 'enqueues nothing yet' do
      expect { listener.on_media_reviewers_updated(media_event) }
        .not_to have_enqueued_job
    end
  end

  describe '#on_organization_reviewers_updated' do
    it 'accepts the event without raising' do
      expect { listener.on_organization_reviewers_updated(organization_event) }.not_to raise_error
    end

    it 'enqueues nothing yet' do
      expect { listener.on_organization_reviewers_updated(organization_event) }
        .not_to have_enqueued_job
    end
  end

  describe 'event subscription' do
    # Bus#attach derives the handler name from the event id, so a rename silently unbinds it.
    it 'responds to the handler name derived from each event id' do
      expect(listener).to respond_to(:on_media_reviewers_updated)
      expect(listener).to respond_to(:on_organization_reviewers_updated)
    end

    it 'is subscribed to the Hyrax publisher' do
      expect(Hyrax.publisher.subscribed?(listener.method(:on_media_reviewers_updated))).to be true
      expect(Hyrax.publisher.subscribed?(listener.method(:on_organization_reviewers_updated))).to be true
    end
  end
end
