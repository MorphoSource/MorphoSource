# Based on but extended from Hyrax::Pageview
module Morphosource
  class Analytics
    class Pageview
      extend ::Legato::Model

      metrics :pageviews
      dimensions :date
      dimensions :page_path
      filter :for_path, &->(path) { contains(:pagePath, path) }
      filter :for_paths, &lambda { |*paths| paths.map { |path| contains(:pagePath, path) } }
    end
  end
end