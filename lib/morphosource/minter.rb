module Morphosource
  module Minter
    extend ActiveSupport::Concern

    included do
      Rails.logger.info("Morphosource::Minter loaded")
      Rails.logger.info("Morphosource::Minter noid-rails namespace: #{::Noid::Rails.config.namespace}")
      Rails.logger.info("Morphosource::Minter noid-rails template: #{::Noid::Rails.config.template}")

      minter = ::Noid::Rails::Service.new.minter.read
      Rails.logger.info("Morphosource::Minter seq: #{minter[:seq]}")
      Rails.logger.info("Morphosource::Minter noid_sequence_start: #{Rails.configuration.noid_sequence_start}")
      if minter[:seq] && (minter[:seq] < Rails.configuration.noid_sequence_start)
        minter[:seq] = Rails.configuration.noid_sequence_start
        ::Noid::Rails::Service.new.minter.write!(minter)
        Rails.logger.info("Morphosource::Minter updated seq: #{minter[:seq]}")
      end
    end
  end
end
