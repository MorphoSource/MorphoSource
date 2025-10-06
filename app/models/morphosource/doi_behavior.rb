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
      byebug
      if self.doi.empty?
        depositor_user_or_org = User.find_by(ms_id: self.user_with_ownership) ||
          OrganizationCollection.where(id: self.user_with_ownership)&.first
        if !depositor_user_or_org.present?
          Rails.logger.error "Failed to mint DOI for media #{self.id} because depositor user or organization not found"
        end

        depositor_params = if depositor_user_or_org.is_a?(User)
          depositor_user_name_components = depositor_user_or_org.display_name.split(' ')
          {
            'author_first' => depositor_user_name_components.first,
            'author_last' => depositor_user_name_components.drop(1).join(' ')
          }
        elsif depositor_user_or_org.is_a?(OrganizationCollection)
          { 'organization' => depositor_user_or_org.display_name }
        else
          { }
        end

        # minted_doi = Morphosource::CrossrefDoiMinter.mint_doi( self.id,
        #                                                       {
        #                                                         'title' => self.title.first,
        #                                                         'url' => target_url,
        #                                                         'resource_type' => self.media_type.first
        #                                                       }.merge(depositor_params) )

        minted_doi = '10.5072/FK2/MYSAMPLEDOI'
        if minted_doi.present?
          # minted_doi may be an exception if mint_doi failed
          unless minted_doi.respond_to?(:message)
            self.doi = [minted_doi]
            self.save
          end
        end
        return minted_doi
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