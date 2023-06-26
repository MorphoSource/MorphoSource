module Morphosource
  module Import
    module Sources

      delegate :sources, to: class

      def self.sources
        @sources ||= YAML.load_file('config/import/slides/sources.yml') || {}
      end

    end
  end
end