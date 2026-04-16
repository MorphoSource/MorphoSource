module Hyrax
  module Actors
    class ImagingEventActor < Hyrax::Actors::BaseActor
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
        # <device parent manufacturer> <device parent name> <modality> Imaging Event (<date created>)
        # For device parent fields and modality field, blank if no value
        # For date created, if no value should be “(No Event Date)”
        attrs = env.attributes
        device_info = ''
        if attrs['device_id'].present?
          device = Hyrax.query_service.find_by(id: attrs['device_id'].first)
          if device.creator.present?
            device_info += "#{device.creator.first} "
          end
          if device.title.present?
            device_info += "#{device.title.first} "
          end
        end
        date_created = attrs['date_created'].present? ? attrs['date_created'].first : 'No Event Date'
        modality = attrs['ie_modality'].present? ? "#{attrs['ie_modality'].first} " : ''
        "#{device_info}#{modality}Imaging Event (#{date_created})"
      end
    end
  end
end
