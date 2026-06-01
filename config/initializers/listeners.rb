# frozen_string_literal: true

# Hyrax 5.0.5 subscribes its default listeners in a plain initializer, outside
# of any to_prepare block. The latest Hyrax fixed this by moving the
# subscription into to_prepare. We replicate that fix here: undo Hyrax's
# boot-time subscription so that to_prepare below has sole ownership of all
# listener subscriptions from this point forward.
#
# Without this, listener instances are not refreshed after a Rails code reload,
# causing:
#   ArgumentError: A copy of <Listener> has been removed from the module tree
#                  but is still active!
Hyrax.publisher.default_listeners.each { |l| Hyrax.publisher.unsubscribe(l) }
Hyrax.publisher.instance_variable_set(:@default_listeners, nil)

# On every prepare cycle (once at boot, then after each code reload), unsubscribe
# the previous instances, reset @default_listeners so fresh class objects are
# used, and re-subscribe everything.
Rails.application.config.to_prepare do
  publisher = Hyrax.publisher

  (Rails.application.config.x.all_event_listeners ||= []).each { |l| publisher.unsubscribe(l) }

  publisher.instance_variable_set(:@default_listeners, nil)
  hyrax_listeners = publisher.default_listeners
  hyrax_listeners.each { |l| publisher.subscribe(l) }

  morphosource_listeners = [
    Morphosource::Listeners::DeleteReservedArkListener,
    Morphosource::Listeners::DestroyProxyDepositRequestsListener,
    Morphosource::Listeners::FileSetSizeInfoListener,
    Morphosource::Listeners::IndexRelatedWorksListener,
    Morphosource::Listeners::MintArkListener,
    Morphosource::Listeners::UpdateArkStatusListener
  ].map { |klass| klass.new.tap { |l| publisher.subscribe(l) } }

  Rails.application.config.x.all_event_listeners = hyrax_listeners.to_a + morphosource_listeners
end
