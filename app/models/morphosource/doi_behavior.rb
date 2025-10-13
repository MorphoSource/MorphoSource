module Morphosource
  module DoiBehavior
    extend ActiveSupport::Concern



    # included do
    #   field :doi, type: Array, default: []
    # end

    # Mints a DOI for this object if it doesn't already have one.
    # Uses Morphosource::CrossrefDoiMinter to mint the DOI.
    # Requires the target_url parameter to specify the URL that the DOI should resolve to.
    # Returns the minted DOI string if successful, or nil if a DOI already exists or minting failed.
    #
    # Example:
    #   minted_doi = object.mint_doi("https://morphosource.org/concern/media/12345")
    #
    # Parameters:
    # - target_url: The URL that the minted DOI should resolve to.
    #
    # Returns:
    # - The minted DOI string if successful, or nil if a DOI already exists or minting failed.

    def mint_doi(target_url)
      return unless self.doi.empty?

      case self
      when Media
        mint_media_doi(target_url)
      when MediaList
        mint_list_doi(target_url)
      else
        raise "DOI minting is only supported for Media and Collection objects"
      end
    end

    def creator_params(creator)
      creator_name_components = creator.display_name.split(' ')
      {
        'author_first' => creator_name_components.first,
        'author_last' => creator_name_components.drop(1).join(' ')
      }
    end

    def contributor_params(contributors)
      contributors = contributors.map { |c| User.find_by(ms_id: c) }.compact
      return {} if contributors.empty?

      {
        'contributors' => contributors.map do |contributor|
          contributor_name_components = contributor.display_name.split(' ')
          {
            'contributor_first' => contributor_name_components.first,
            'contributor_last' => contributor_name_components.drop(1).join(' ')
          }
        end
      }
    end

    def component_params(media)
      return {} if media.empty?
      {
        'components': media.map do |m|
          { 'doi' => m.doi.first,
            'title' => m.title.first,
            'resource_type' => m.media_type.first,
            'url' => Rails.application.routes.url_helpers.media_showcase_url(m, host: Hyrax.config.host_name)
          }
        end
      }
    end

    def verify_creator
      User.find_by(ms_id: self.creator&.first)
    end

    def mint_list_doi(target_url)
      byebug
      unless creator = verify_creator
        Rails.logger.error "Failed to mint DOI for media list #{self.id} because creator user was not found"
      else
        byebug
        creator_params = creator_params(creator)
        contributor_params = contributor_params(self.contributor)
        component_params = component_params(self.media)

        params = {
                  'title' => self.title.first,
                  'url' => target_url
                  }

        params = params.merge(creator_params).merge(contributor_params).merge(component_params)

        byebug
        minted_doi = Morphosource::CrossrefListDoiMinter.mint_doi( self.id, params)
        byebug
        minted_doi = '10.5072/FK2/MYSAMPLEDOI'
        if minted_doi.present?
          # minted_doi may be an exception if mint_doi failed
          unless minted_doi.respond_to?(:message)
            self.doi = [minted_doi]
            self.save
          end
        end
        []
      end
    end

    private

    def prevent_doi_deletion
      unless self.doi.empty?
        throw(:abort)
      end
    end
  end
end