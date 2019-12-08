# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor
      include MorphosourceHelper

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
        #parts = attrs['part'].presence || ['Element unspecified']
        id = attrs['id'].presence || env.curation_concern.id.presence || ''
        part = attrs['part']
        media_type = attrs['media_type']
        # get the modality from the parent imaging event
        ie_modality = []
        if attrs['work_parents_attributes'].present?
          attrs['work_parents_attributes'].each do |key, wp|
            work_parent = Morphosource::Works::Base.find(wp['id'])
            work_parent_string = case work_parent.class.to_s
              when 'ImagingEvent'
                "#{work_parent.ie_modality.first}"
            end
            ie_modality << "#{work_parent_string}"
          end
        elsif id.present?
          # todo: might need to handle if processing event exist?
          imaging_event = ImagingEvent.where('member_ids_ssim' => id).first
          if imaging_event.present?
            ie_modality << imaging_event.ie_modality.first
          end
        end
        # MorphosourceHelper's generated_media_title method is shared by different actors 
        # (e.g. media actor, IE actor)
        updated_title = generated_media_title(id, part, media_type, ie_modality)
        updated_title
      end

      private

      def generated_title_parts(attrs)
        attrs['part'].sort.join(', ').titleize
      end

      def modalities_service
        @modalities_service ||= Morphosource::ModalitiesService.new
      end

    end
  end
end
