module Morphosource
  module Facets
    # Solr id lookups shared by facet searching in the catalog search builder
    # (add_facet_filter) and the id-helper facet "more" modal
    # (Morphosource::Facets::Collections).
    module SolrTitleLookup

      MODEL_FILTERS = {
        'team'             => 'has_model_ssim:Collection AND human_readable_type_tesim:Team',
        'project'          => 'has_model_ssim:Collection AND human_readable_type_tesim:Project',
        'media_list'       => 'has_model_ssim:MediaList',
        'seq_section_list' => 'has_model_ssim:SequentialSectionList',
        'object'           => 'has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)',
        'organization'     => 'has_model_ssim:OrganizationCollection',
        'device'           => 'has_model_ssim:DeviceResource'
      }.freeze

      # Returns ids of the facet's model whose title matches, or nil when there
      # is no search term. Callers must distinguish nil (no filtering requested)
      # from [] (a search that matched nothing). The model restriction goes in
      # fq (filter query) so OR only ever appears in a filter query, never in
      # the main q param, and Solr can cache it.
      def fetch_ids_by_title(title, facet_key)
        return nil if title.blank?

        model_fq = MODEL_FILTERS[facet_key]
        if model_fq.nil?
          Rails.logger.warn("Unknown model for facet key: #{facet_key}")
          model_fq = 'has_model_ssim:unknown'
        end

        params = {
          q: "title_tesim:#{solr_phrase(title)}",
          fq: [model_fq],
          fl: 'id',
          rows: 999999
        }
        response = Blacklight.default_index.connection.get('select', params: params)
        response['response']['docs'].map { |doc| doc['id'] }
      end

      # Returns ids of Users matching by display name, or nil when there is no
      # search term.
      def fetch_user_ids_by_name(name)
        return nil if name.blank?

        User.where('display_name ILIKE ?', "%#{name}%").pluck(:ms_id).map(&:to_s)
      end

      # Returns ids of Users matching by display name plus OrganizationCollections
      # matching by title, or nil when there is no search term.
      # OrganizationCollections can also own media and are resolved by
      # user_name_by_id, so an org shown in the owner facet must be findable by
      # typing its name in the facet search box.
      def fetch_owner_ids_by_name(name)
        return nil if name.blank?

        fetch_user_ids_by_name(name) + fetch_ids_by_title(name, 'organization')
      end

      # Quote user input as a Solr phrase, escaping the characters that would
      # terminate the phrase; other Lucene specials are inert inside quotes.
      def solr_phrase(text)
        "\"#{text.gsub(/["\\]/) { |c| "\\#{c}" }}\""
      end
    end
  end
end
