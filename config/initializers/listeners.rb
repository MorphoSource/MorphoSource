# frozen_string_literal: true

# Wrapped in to_prepare so listener instances are re-registered after each
# Rails code reload in development, preventing stale instances from raising:
#   ArgumentError: A copy of <Listener> has been removed from the module tree
#                  but is still active!
# Instances are stored in config.x so they can be unsubscribed on the next
# prepare cycle before fresh ones are created.
Rails.application.config.to_prepare do
  publisher = Hyrax.publisher
  stored_listeners = Rails.application.config.x.morphosource_event_listeners ||= []

  # Clear previously registered listener instances before reloading classes.
  stored_listeners.each { |listener| publisher.unsubscribe(listener) }

  listener_classes = [
    Morphosource::Listeners::DeleteReservedArkListener,
    Morphosource::Listeners::DestroyProxyDepositRequestsListener,
    Morphosource::Listeners::IndexRelatedWorksListener,
    Morphosource::Listeners::MintArkListener,
    Morphosource::Listeners::UpdateArkStatusListener
  ]

  Rails.application.config.x.morphosource_event_listeners =
    listener_classes.map do |listener_class|
      listener_class.new.tap { |listener| publisher.subscribe(listener) }
    end
end
