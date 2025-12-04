module Morphosource
  module DoiBehavior
    extend ActiveSupport::Concern

    def mint_doi(target_url)
      @target_url = target_url
      raise StandardError.new "DOI already exists" if self.doi.present?
      raise StandardError.new "Creator user or organization was not found" unless

      @creator = verify_creator
      raise StandardError.new "Creator display name is nil" if @creator.display_name.empty?

      minted_doi = self.is_a?(Media) ? mint_media_doi : mint_list_doi

      if minted_doi.respond_to?(:message)
        raise minted_doi
      elsif minted_doi.present?
        self.doi = [minted_doi]
        self.save!
      end

      minted_doi
    rescue StandardError => e
      Rails.logger.error "Error minting DOI for MediaList #{self.id}: #{e.message}"
      e
    end

    private

    def mint_media_doi
      params = base_params.merge(creator_params)
                          .merge(format_params)

      Morphosource::CrossrefDoiMinter.mint_doi(self.id, params)
    end

    def mint_list_doi
      params = base_params.merge(creator_params)
                          .merge(contributor_params)
                          .merge(component_params)

      Morphosource::CrossrefDoiMinter.mint_doi(self.id, params)
    end

    def base_params
      { 'title' => self.title.first,
        'url' => @target_url
      }
    end

    def contributor_params
      contributors = self.contributor.map { |c| User.find_by(ms_id: c) }.compact
      return {} if contributors.empty?

      {
        'contributors' => contributors.map do |contributor|
          first_name, last_name = name_components(contributor.display_name)
          {
            'contributor_first' => first_name,
            'contributor_last' => last_name
          }
        end
      }
    end

    def component_params
      media = self.media
      raise StandardError.new "No media in list" if media.empty?

      missing_dois = media.select { |m| m.doi.empty? }.map(&:id)
      raise StandardError.new "MediaList #{self.id} has media without DOIs: #{missing_dois.join(', ')}" unless missing_dois.empty?

      {
        'components' => media.map do |m|
          { 'doi' => m.doi.first,
            'title' => "#{m.id}: #{m.title.first}",
            'resource_type' => m.media_type.first,
            'url' => Rails.application.routes.url_helpers.media_showcase_url(m, host: Hyrax.config.host_name)
          }
        end
      }
    end

    def creator_params
      if @creator.is_a? OrganizationCollection
        {
          'organization' => @creator.display_name
        }
      else
        first_name, last_name = name_components(@creator.display_name)
        {
          'author_first' => first_name,
          'author_last' => last_name
        }
      end
    end

    def format_params
      { 'resource_type' => self.media_type.first }
    end

    def name_components(display_name)
      components = display_name&.split(' ')
      last_name = components&.pop || ''
      first_name = components&.join(' ') || ''
      return first_name, last_name
    end

    def prevent_doi_deletion
      unless self.doi.empty?
        throw(:abort)
      end
    end

    def verify_creator
      # media
      User.find_by(ms_id: self.try(:user_with_ownership)) ||
      OrganizationCollection.find_by(id: self.try(:user_with_ownership)) ||
      # media list
      User.find_by(ms_id: self.creator&.first) ||
      OrganizationCollection.find_by(id: self.creator&.first)
    end
  end
end