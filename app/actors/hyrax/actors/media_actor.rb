# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        attrs = env.attributes
        if attrs['part'].present?
          "#{generated_title_parts(attrs)} [#{generated_title_modalities(attrs)}]"
        else
          "[#{generated_title_modalities(attrs)}]"
        end
      end

      private

      def generated_title_modalities(attrs)
        attrs['modality'].map { |m| modalities_service.label(m) }.sort.join(', ')
      end

      def generated_title_parts(attrs)
        attrs['part'].sort.join(', ').titleize
      end

      def modalities_service
        @modalities_service ||= Morphosource::ModalitiesService.new
      end

    end
  end
end
