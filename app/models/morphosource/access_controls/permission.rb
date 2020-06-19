module Morphosource
  module AccessControls
    module Permission

      def build_access(access)
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

Hydra::AccessControls::Permission.prepend Morphosource::AccessControls::Permission
