module Morphosource
  module AccessControls
    module DownloadPermissions

      # Return a list of groups that have download permission
      def download_groups
        search_by_type_and_mode(:group, Morphosource::ACL.Download).map(&:agent_name)
      end

      # Grant download permissions to the groups specified. Revokes download permission for all other groups.
      # @param[Array] groups a list of group names
      # @example
      #  r.download_groups= ['one', 'two', 'three']
      #  r.download_groups
      #  => ['one', 'two', 'three']
      #
      def download_groups=(groups)
        set_download_groups(groups, download_groups)
      end

      # Grant download permissions to the groups specified. Revokes download permission for all other groups.
      # @param[String] groups a list of group names
      # @example
      #  r.download_groups_string= 'one, two, three'
      #  r.download_groups
      #  => ['one', 'two', 'three']
      #
      def download_groups_string=(groups)
        self.download_groups = groups.split(/[\s,]+/)
      end

      # Display the groups a comma delimeted string
      def download_groups_string
        download_groups.join(', ')
      end

      # Grant download permissions to the groups specified. Revokes download permission for
      # any of the eligible_groups that are not in groups.
      # This may be used when different users are responsible for setting different
      # groups.  Supply the groups the current user is responsible for as the
      # 'eligible_groups'
      # @param[Array] groups a list of groups
      # @param[Array] eligible_groups the groups that are eligible to have their discover permssion revoked.
      # @example
      #  r.download_groups = ['one', 'two', 'three']
      #  r.download_groups
      #  => ['one', 'two', 'three']
      #  r.set_download_groups(['one'], ['three'])
      #  r.download_groups
      #  => ['one', 'two']  ## 'two' was not eligible to be removed
      #
      def set_download_groups(groups, eligible_groups)
        set_entities(:download, :group, groups, eligible_groups)
      end

      def download_users
        search_by_type_and_mode(:person, Morphosource::ACL.Download).map(&:agent_name)
      end

      # Grant download permissions to the users specified. Revokes download permission for all other users.
      # @param[Array] users a list of usernames
      # @example
      #  r.download_users= ['one', 'two', 'three']
      #  r.download_users
      #  => ['one', 'two', 'three']
      #
      def download_users=(users)
        set_download_users(users, download_users)
      end

      # Grant download permissions to the groups specified. Revokes download permission for all other users.
      # @param[String] users a list of usernames
      # @example
      #  r.download_users_string= 'one, two, three'
      #  r.download_users
      #  => ['one', 'two', 'three']
      #
      def download_users_string=(users)
        self.download_users = users.split(/[\s,]+/)
      end

      # Display the users as a comma delimeted string
      def download_users_string
        download_users.join(', ')
      end

      # Grant download permissions to the users specified. Revokes download permission for
      # any of the eligible_users that are not in users.
      # This may be used when different users are responsible for setting different
      # users.  Supply the users the current user is responsible for as the
      # 'eligible_users'
      # @param[Array] users a list of users
      # @param[Array] eligible_users the users that are eligible to have their download permssion revoked.
      # @example
      #  r.download_users = ['one', 'two', 'three']
      #  r.download_users
      #  => ['one', 'two', 'three']
      #  r.set_download_users(['one'], ['three'])
      #  r.download_users
      #  => ['one', 'two']  ## 'two' was not eligible to be removed
      #
      def set_download_users(users, eligible_users)
        set_entities(:download, :person, users, eligible_users)
      end

      private

        def set_entities(permission, type, values, changeable)
          (changeable - values).each do |entity|
            for_destroy = select_permission(type, permission, entity)
            permissions.delete(for_destroy)
          end

          values.each do |agent_name|
            exists = select_permission(type, permission, agent_name)
            permissions.build(name: agent_name, access: permission.to_s, type: type) unless exists.present?
          end
        end

        def select_permission(type, permission, value)
          search_by_type_and_mode(type, permission_to_uri(permission)).select { |p| p.agent_name == value.to_s }
        end

        def permission_to_uri(permission)
          case permission.to_s
          when 'read'
            ::ACL.Read
          when 'edit'
            ::ACL.Write
          when 'discover'
            Hydra::ACL.Discover
          when 'download'
            Morphosource::ACL.Download
          else
            raise "Invalid permission #{permission.inspect}"
          end
        end 

    end
  end
end
