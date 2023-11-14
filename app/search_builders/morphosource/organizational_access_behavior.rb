module Morphosource
  module OrganizationalAccessBehavior
    # Returns media associated with an organization if the current user is a member of the OrganizationCollection

    # this is modeled on blacklight-access-controls :apply_group_permissions
    # https://github.com/projectblacklight/blacklight-access_controls/blob/cb6815bf2f5f0c9559d85f0f2e9ba4f9757feecc/lib/blacklight/access_controls/enforcement.rb#L64
    def apply_organization_permissions(permission_types = [], ability = current_ability)
      groups = ability.user_groups.dup
      roles = ['_managers','_editors','_downloaders','_viewers']
      groups.select!{|group| roles.any? { |role| group.include?(role) } }
      return [] if groups.empty?

      field = 'media_organization_id_ssim'
      collection_ids = groups.map{|group| group.split('_').first}
      ["({!terms f=#{field}}#{collection_ids.join(',')})"]
    end

    def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
      [:apply_user_permissions, :apply_group_permissions, :apply_organization_permissions].map { |method| send(method, permission_types, ability).reject(&:blank?) }.reject(&:empty?)
    end
  end
end