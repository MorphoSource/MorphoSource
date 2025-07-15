module Morphosource
  module AccessControls
    module Permission

      # agent_name and build_agent_resource updated per: https://github.com/samvera/hydra-head/pull/532 to stop annoying deprecation warnings.
      def agent_name
        decode(parsed_agent.last)
      end

      def build_agent_resource(prefix, name)
        [Hydra::AccessControls::Agent.new(::RDF::URI.new("#{prefix}##{encode(name)}"))]
      end

      def build_access(access)
        puts "!!!!!!!! Morphosource::AccessControls::Permission#build_access called with access: #{access}"
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

      private

        def encode(str)
          URI::RFC2396_Parser.new.escape(str)
        end

        def decode(str)
          URI::RFC2396_Parser.new.unescape(str)
        end

    end
  end
end

Hydra::AccessControls::Permission.prepend Morphosource::AccessControls::Permission
