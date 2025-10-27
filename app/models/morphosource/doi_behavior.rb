module Morphosource
  module DoiBehavior
    extend ActiveSupport::Concern

    def mint_doi(target_url)
      return unless self.doi.empty?
    end

    private

    def prevent_doi_deletion
      unless self.doi.empty?
        throw(:abort)
      end
    end

  end
end