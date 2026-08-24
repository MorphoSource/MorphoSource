# frozen_string_literal: true

require 'rails_helper'

# Guards config/initializers/listeners.rb: register on the publisher instance, above
# the subscribe loop, or handlers silently never fire.
RSpec.describe 'reviewer domain event registration' do
  let(:event_ids) { ['media.reviewers.updated', 'organization.reviewers.updated'] }

  def registered_event_ids
    Hyrax.publisher.send(:__bus__).events.keys
  end

  def subscribed_to?(handler)
    Hyrax.publisher.subscribed?(Morphosource::Listeners::ReviewerUpdateListener.new.method(handler))
  end

  it 'registers both events on the bus the publisher instance actually uses' do
    expect(registered_event_ids).to include(*event_ids)
  end

  it 'publishes each event without raising UnregisteredEventError' do
    expect { Hyrax.publisher.publish('media.reviewers.updated', media_id: 'x') }.not_to raise_error
    expect { Hyrax.publisher.publish('organization.reviewers.updated', organization_id: 'x') }.not_to raise_error
  end

  it 'subscribes ReviewerUpdateListener to both events' do
    expect(subscribed_to?(:on_media_reviewers_updated)).to be true
    expect(subscribed_to?(:on_organization_reviewers_updated)).to be true
  end

  # Bus#attach never retro-attaches, so a shift in load order would break this silently.
  it 'survives a to_prepare reload cycle' do
    expect { Rails.application.reloader.prepare! }.not_to raise_error

    expect(registered_event_ids).to include(*event_ids)
    expect(subscribed_to?(:on_media_reviewers_updated)).to be true
    expect(subscribed_to?(:on_organization_reviewers_updated)).to be true
  end
end
