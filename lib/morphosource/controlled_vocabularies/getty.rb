module Morphosource
  module ControlledVocabularies
    module Getty
      include ::Morphosource::ControlledVocabularies::ResourceLabelCaching

      # include Morphosource::GettyService


      # Return a tuple of url & label
      # def solrize
      #   return [rdf_subject.to_s] if label.blank? || label == rdf_subject.to_s
      #   [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      # end

      # Return a tuple of url & label
      def solrize
        byebug
        getty_label = full_label || rdf_subject.first.to_s
        return [rdf_subject.to_s] if label.blank? || label == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      end

      # def label_english
      #   fetch.rdf_label.select{|l| l.language == :en}.first || rdf_subject.to_s
      # end
      # alias label label_english

      # def full_label
      #   byebug
      #   Morphosource::GettyService.new.full_label(rdf_subject.to_s)
      # end
      # alias label full_label

      CACHE_KEY_PREFIX = 'morphosource_getty_label-v1-'
      CACHE_EXPIRATION = 1.week

      def full_label
        return if rdf_subject.to_s.blank?
        id = extract_id rdf_subject.to_s
        Rails.cache.fetch(cache_key(id), expires_in: CACHE_EXPIRATION) do
          byebug
          label.call(find(id))
        end
      end
      alias english_label full_label

      def find(id)
        json(find_url(id))
      end

      ##
      # @note uses the Rails cache to avoid repeated lookups.
      # @see ActiveTriples::Resource#rdf_label
      def rdf_label
        # only cache if this rdf source is represented by a URI;
        # i.e. don't cache for blank nodes
        return super unless uri?

        byebug
        Rails.cache.fetch(cache_key(id)) { super }
      end



      private

      def extract_id(uri)
        uri.split('/').last
      end

      def cache_key(id)
        byebug
        "#{CACHE_KEY_PREFIX}#{id}"
      end

    end
  end
end
