module Morphosource
  module OrganizationalAccessBehavior

    # adds access to media that a user can view because of their membership in an organization
    # to add to a search builder:
    # include Morphosource::OrganizationalAccessBehavior
    # self.default_processor_chain += [:add_organizational_access_to_solr_params]

    def add_organizational_access_to_solr_params(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << organization_access.reject(&:blank?).join(' OR ')
      Rails.logger.debug("Solr parameters: #{solr_parameters.inspect}")
    end

    # retrieve media for current_user's organizations
    def organization_access(ability = current_ability)
      groups = ability.user_groups
      roles = ['_managers','_editors','_downloaders','_viewers']
      groups.select!{|group| roles.any? { |role| group.include?(role) } }
      return [] if groups.empty?
      field = 'media_organization_id_ssim'
      collection_ids = groups.map{|group| group.split('_').first}
      ["({!terms f=#{field}}#{collection_ids.join(',')})"]
    end
  end
end