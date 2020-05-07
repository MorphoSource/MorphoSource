module Morphosource
  module Minter
    extend ActiveSupport::Concern

    included do
      Rails.logger.info("Morphosource::Minter loaded")
      Rails.logger.info("Morphosource::Minter noid-rails namespace: #{::Noid::Rails.config.namespace}")
      Rails.logger.info("Morphosource::Minter noid-rails template: #{::Noid::Rails.config.template}")

      begin
        minter = ::Noid::Rails::Service.new.minter.read
        Rails.logger.info("Morphosource::Minter seq: #{minter[:seq]}")
        Rails.logger.info("Morphosource::Minter noid_sequence_start: #{Rails.configuration.noid_sequence_start}")
        if minter[:seq] && (minter[:seq] < Rails.configuration.noid_sequence_start)
          (Rails.configuration.noid_sequence_start - minter[:seq]).times do
            ::Noid::Rails::Service.new.minter.mint
          end
          Rails.logger.info("Morphosource::Minter updated seq: #{::Noid::Rails::Service.new.minter.read[:seq]}")
        end
      rescue StandardError => e
        Rails.logger.error("Morphosource::Minter error: #{e.inspect} #{e.backtrace}")
      end
    end
  end
end
