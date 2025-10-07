module Morphosource
  module ValkyrieFormBehavior
    extend ActiveSupport::Concern

    included do
      property :id, prepopulator: :id_prepopulator
    end

    private

    def id_prepopulator
      self.id ||= ::Noid::Rails::Service.new.mint
    end
  end
end