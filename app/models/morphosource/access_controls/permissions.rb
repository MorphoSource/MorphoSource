module Morphosource
  module AccessControls
    module Permissions
      extend ActiveSupport::Concern
      include Morphosource::AccessControls::Permission
      include Morphosource::AccessControls::DownloadPermissions
      include Hydra::AccessControls::Permissions
      include Hydra::AccessControls::Visibility

      # Morphosource::AccessControls::Permission prepend is not always caught by Resque jobs in Docker
      included do
        Hydra::AccessControls::Permission.prepend Morphosource::AccessControls::Permission
      end

      def build_access(access)
        puts "!!!!!!!! Morphosource::AccessControls::Permissions#build_access called with access: #{access}"
        raise "Can't build access #{inspect}" unless access
        self.mode = case access
                    when 'read'
                      [Hydra::AccessControls::Mode.new(::ACL.Read)]
                    when 'edit'
                      [Hydra::AccessControls::Mode.new(::ACL.Write)]
                    when 'discover'
                      [Hydra::AccessControls::Mode.new(Hydra::ACL.Discover)]
                    when 'download'
                      [Hydra::AccessControls::Mode.new(Morphosource::ACL.Download)]
                    else
                      raise ArgumentError, "Unknown access #{access.inspect}"
                    end
      end
    end
  end
end
