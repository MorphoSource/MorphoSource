module Morphosource
  module ControlledVocabularies
    module GettyAuthorities
      include Morphosource::ControlledVocabularies::WebServiceBase

      CACHE_EXPIRATION = 1.week

      # Return a tuple of url & label
      def solrize
        term_label = rdf_label.first || rdf_subject.to_s
        return [rdf_subject.to_s] if term_label.blank? || term_label == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{term_label}$#{rdf_subject}" }]
      end

      ##
      # @note uses the Rails cache to avoid repeated lookups.
      # @see ActiveTriples::Resource#rdf_label
      def rdf_label
        # only cache if this rdf source is represented by a URI;
        # i.e. don't cache for blank nodes
        return super unless uri?

        Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
          item = getty_json(id)
          if item.nil?
            Rails.cache.delete(cache_key)
            return ["Error fetching #{extract_id(self.id)}"]
          else
            [item["_label"]]
          end
        end
      end

      # note adds behavior to clear the cache whenever a manual fetch of data
      #   is performed.
      # see ActiveTriples::Resource#fetch
      def fetch(*)
        Rails.cache.delete(cache_key)
        super
      end

      private

        def extract_id(uri)
          uri.split('/').last
        end

        def cache_key
          id = extract_id(self.id)
          "#{cache_key_prefix}#{id}"
        end

        def getty_json(id)
          begin
            response = RestClient.get(id + ".json")
            JSON.parse(response.body)
          rescue
            nil
          end
        end
    end
  end
end
