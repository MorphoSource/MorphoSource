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
        
        # skipping media update.  This should not be needed unless an IE is updated
        # by itself.  Updating title will be handled in Media actor when media is saved.

        # look for media associated with this IE (child works)
        # for each media, update the media title with the IE modality
        #media_ids = []
        #if env.curation_concern.ordered_work_ids.present?
        #  env.curation_concern.ordered_work_ids.each do |child_id|
        #    work_child = Morphosource::Works::Base.find(child_id)
        #    case work_child.class.to_s
        #    when 'Media'
        #      media_ids << work_child.id
        #    end              
        #  end
        #  media_ids.each do |media_id|
        #    media = ::ActiveFedora::Base.find(media_id)
        #    updated_title = generated_media_title(media_id, media.part, media.media_type, env.attributes['ie_modality']#)#
        #    med#ia.title = [updated_title]#
        #    media.save!#
        #  end
        #end

        super
      end

      def generated_title(env)
        # <device parent manufacturer> <device parent name> <modality> Imaging Event (<date created>)
        # For device parent fields and modality field, blank if no value
        # For date created, if no value should be “(No Event Date)”
        attrs = env.attributes
        work_parents = ''
        if attrs['work_parents_attributes'].present?
          attrs['work_parents_attributes'].each do |key, wp|
            work_parent = Morphosource::Works::Base.find(wp['id'])
            work_parent_string = case work_parent.class.to_s
              when 'Device'
                "#{work_parent.creator.first} #{work_parent.title.first}"
              # when 'BiologicalSpecimen'
              #   "S#{wp['id']} "
              # when 'CulturalHeritageObject'
              #   "C#{wp['id']} "
            end
            work_parents += "#{work_parent_string} "
          end
        end
        date_created = attrs['date_created'].present? ? attrs['date_created'].first : 'No Event Date'
        modality = attrs['modality'].present? ? "#{attrs['modality'].first} " : ''
        "#{work_parents}#{modality}Imaging Event (#{date_created})"
      end
    end
  end
end
