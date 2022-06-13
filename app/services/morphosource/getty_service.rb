# frozen_string_literal: true
module Morphosource
  class GettyService

    include Qa::Authorities::Getty

    CACHE_KEY_PREFIX = 'morphosource_getty_label-v1-'
    CACHE_EXPIRATION = 1.week

    def full_label(uri)
      byebug
      return if uri.blank?
      id = extract_id uri
      Rails.cache.fetch(cache_key(id), expires_in: CACHE_EXPIRATION) do
        label.call(find(id))
      end
    end

    private

    def extract_id(obj)
      byebug
      uri = case obj
            when String
              URI(obj)
            when URI
              obj
            else
              raise ArgumentError, "#{obj} is not a valid type"
            end
      uri.path.split('/').last
    end

    def cache_key(id)
      byebug
      "#{CACHE_KEY_PREFIX}#{id}"
    end
  end
end
