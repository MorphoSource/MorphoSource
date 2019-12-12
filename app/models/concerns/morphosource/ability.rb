module Morphosource
  module Ability
    extend ActiveSupport::Concern
    included do
      include Hyrax::Ability
    end

    def download_groups(id)
      Rails.logger.info('Morphosource::Ability.download_groups called')
      return []
    end
    def download_users(id)
      Rails.logger.info('Morphosource::Ability.download_users called')
      return []
    end
  end
end
    
Hyrax::Ability.prepend Morphosource::Ability
