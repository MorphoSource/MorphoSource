module Morphosource
  module Collections
    class MediaListPresenter < Morphosource::CollectionPresenter

      def creator_list(creators)
        cl = []
        creators.each do |c|
          renderer = Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer.new(nil,nil)
          cl << renderer.user_link(c)
        end
        cl.join(', ').html_safe
      end

    end
  end
end
