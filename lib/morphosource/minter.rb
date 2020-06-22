module Morphosource
  module Minter
    extend ActiveSupport::Concern

    included do
      Rails.logger.info("Morphosource::Minter loaded")
      Rails.logger.info("Morphosource::Minter noid-rails namespace: #{::Noid::Rails.config.namespace}")
      Rails.logger.info("Morphosource::Minter noid-rails template: #{::Noid::Rails.config.template}")
      Rails.logger.info("Morphosource::Minter noid-rails minter class: #{::Noid::Rails.config.minter_class.to_s}")
      Rails.logger.info("Morphosource::Minter noid_sequence_start: #{Rails.configuration.noid_sequence_start}")

      begin
        if (::Noid::Rails.config.minter_class == Noid::Rails::Minter::Db) && (ActiveRecord::Base.connection.table_exists?('minter_states'))
          minter = ::Noid::Rails::Service.new.minter.read
          Rails.logger.info("Morphosource::Minter seq: #{minter[:seq]}")
          if minter[:seq] && (minter[:seq].to_i < Rails.configuration.noid_sequence_start)
            Rails.logger.info("Morphosource::Minter initializing DB-backed minter state")
            ActiveRecord::Base.connection.execute("UPDATE minter_states SET seq = #{Rails.configuration.noid_sequence_start} WHERE minter_states.namespace = '#{::Noid::Rails.config.namespace}' AND seq < #{Rails.configuration.noid_sequence_start}")
          end
        end
        minter = ::Noid::Rails::Service.new.minter.read
        Rails.logger.info("Morphosource::Minter seq: #{minter[:seq]}")
        if minter[:seq] && (minter[:seq].to_i < Rails.configuration.noid_sequence_start)
          (Rails.configuration.noid_sequence_start - minter[:seq].to_i).times do
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
