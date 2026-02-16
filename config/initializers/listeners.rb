# frozen_string_literal: true

Rails.application.config.to_prepare do
  publisher = Hyrax.publisher
  stored_listeners = Rails.application.config.x.morphosource_event_listeners ||= []

  # Clear previously registered listener instances before reloading classes.
  stored_listeners.each { |listener| publisher.unsubscribe(listener) }

  listener_classes = [
    Morphosource::Listeners::DeleteDeviceReservedArkListener,
    Morphosource::Listeners::DestroyProxyDepositRequestsListener,
    Morphosource::Listeners::IndexRelatedWorksListener,
    Morphosource::Listeners::MintDeviceArkListener,
    Morphosource::Listeners::UpdateDeviceArkStatusListener
  ]

  Rails.application.config.x.morphosource_event_listeners =
    listener_classes.map do |listener_class|
      listener_class.new.tap { |listener| publisher.subscribe(listener) }
    end
end
