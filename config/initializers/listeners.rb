# Wrapped in `to_prepare` so listener instances are re-registered after every
# Rails code reload in development. Without this, the old instances (created at
# boot) remain subscribed to Hyrax.publisher while their classes have been
# removed from the module tree, causing:
#   ArgumentError: A copy of <Listener> has been removed from the module tree
#                  but is still active!
# In production, `to_prepare` runs only once (same behaviour as a plain
# initializer), so there is no regression there.
Rails.application.config.to_prepare do
  Hyrax.publisher.subscribe(Morphosource::Listeners::DeleteReservedArkListener.new)
  Hyrax.publisher.subscribe(Morphosource::Listeners::DestroyProxyDepositRequestsListener.new)
  Hyrax.publisher.subscribe(Morphosource::Listeners::IndexRelatedWorksListener.new)
  Hyrax.publisher.subscribe(Morphosource::Listeners::MintArkListener.new)
  Hyrax.publisher.subscribe(Morphosource::Listeners::UpdateDeviceArkStatusListener.new)
end
