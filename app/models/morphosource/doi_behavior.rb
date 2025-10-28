module Morphosource
  module DoiBehavior
    extend ActiveSupport::Concern

    # def mint_doi(target_url)
    #   raise StandardError.new "DOI already exists" if self.doi.present?
    # rescue StandardError => e
    #   Rails.logger.error "Error minting DOI for MediaList #{self.id}: #{e.message}"
    #   return nil
    # end

    def mint_doi(target_url)
      raise StandardError.new "DOI already exists" if self.doi.present?
      unless creator = verify_creator
        raise StandardError.new "Failed to mint DOI for media list #{self.id} because creator user was not found"
      else
        creator_params = creator_params(creator)
        contributor_params = contributor_params(self.contributor)
        component_params = component_params(self.media)

        params = {
                  'title' => self.title.first,
                  'url' => target_url
                  }

        params = params.merge(creator_params).merge(contributor_params).merge(component_params)

        minted_doi = Morphosource::CrossrefListDoiMinter.mint_doi(self.id, params)
        # minted_doi = '10.5072/FK2/MYSAMPLEDOI'
        if minted_doi.present?
          # minted_doi may be an exception if mint_doi failed
          unless minted_doi.respond_to?(:message)
            self.doi = [minted_doi]
            self.save
          end
        end
        minted_doi
      end
    rescue StandardError => e
      Rails.logger.error "Error minting DOI for MediaList #{self.id}: #{e.message}"
      e
    end

    private

    def creator_params(creator)
      if creator.is_a? OrganizationCollection
        {
          'organization' => creator.display_name
        }
      else
        creator_name_components = creator.display_name.split(' ')
        {
          'author_first' => creator_name_components.first,
          'author_last' => creator_name_components.drop(1).join(' ')
        }
      end
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
      missing_dois = media.select { |m| m.doi.empty? }.map(&:id)
      raise StandardError.new "MediaList #{self.id} has media without DOIs: #{missing_dois.join(', ')}" unless missing_dois.empty?
      {
        'components': media.map do |m|
          { 'doi' => m.doi.first,
            'title' => "#{m.id}: #{m.title.first}",
            'resource_type' => m.media_type.first,
            'url' => Rails.application.routes.url_helpers.media_showcase_url(m, host: Hyrax.config.host_name)
          }
        end
      }
    end

    def prevent_doi_deletion
      unless self.doi.empty?
        throw(:abort)
      end
    end

    def verify_creator
      User.find_by(ms_id: self.creator&.first) || OrganizationCollection.find_by(id: self.creator&.first)
    end

  end
end