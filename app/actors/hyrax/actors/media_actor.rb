# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor
      include MorphosourceHelper
      include Morphosource::LinkedTeams::LinkedTeamsManagement

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['physical_object_id'] = find_physical_object_parents(env)
        add_team_access(env)
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['physical_object_id'] = find_physical_object_parents(env)
        super
      end

      def generated_title(env)
        attrs = env.attributes
        id = attrs['id'].presence || env.curation_concern.id.presence || ''
        part = attrs['part'].presence || env.curation_concern.part.presence || ''
        media_type = attrs['media_type'].presence || env.curation_concern.media_type.presence || ''

        # get the modality from the parent imaging event
        ie_modality = []

        if attrs['work_parents_attributes'].present?
          # Adding or changing parents
          attrs['work_parents_attributes'].each do |key, wp|
            work_parent = Morphosource::Works::Base.find(wp['id'])
            if work_parent.class.to_s == 'ImagingEvent'
              ie_modality << work_parent.ie_modality&.first
            elsif work_parent.class.to_s == 'ProcessingEvent'
              ie = work_parent.imaging_event
              ie_modality << ie.ie_modality&.first if ie.present?
            end
          end
        elsif id.present? && Media.exists?(id)
          # Updating work, not updating parents
          imaging_event = Media.find(id).imaging_event
          ie_modality << imaging_event.ie_modality&.first if imaging_event.present?
        else 
          ie_modality = []
        end
        
        # MorphosourceHelper's generated_media_title method is shared by different actors
        # (e.g. media actor, IE actor)
        updated_title = generated_media_title(part, media_type, ie_modality)
        updated_title
      end

      private

      def generated_title_parts(attrs)
        attrs['part'].sort.join(', ').titleize
      end

      def modalities_service
        @modalities_service ||= Morphosource::ModalitiesService.new
      end

      def find_physical_object_parents(env)
        attrs = env.attributes
        id = attrs['id'].presence || env.curation_concern.id.presence || ''
        
        physical_object_parents = []

        if attrs['work_parents_attributes'].present?
          parents = attrs['work_parents_attributes'].map do |key, wp|  
            wp['id'] if [ImagingEvent, ProcessingEvent].include?(
              Morphosource::Works::Base.find(wp['id']).class
            )
          end

          physical_object_parents += parents.
            map { |p_id| Morphosource::PhysicalObjectParentSearchService.call({ id: p_id }) }.
            flatten.
            map { |po| po.id }
        end

        if id.present? && Media.exists?(id)
          physical_object_parents += Media.find(id).physical_objects.map { |po| po.id }
        end

        physical_object_parents.uniq
      end

      def add_team_access(env)
        return unless env.attributes[:work_parents_attributes]

        find_parent(env)
        return if new_orgs.empty?

        add_organization_team_access([env.curation_concern])
      end

      def new_specimens
        ancestors = @parent.ancestors
        select_specimens(ancestors)
      end

      def find_parent(env)
        parent_id = env.attributes[:work_parents_attributes].values.first['id']
        @parent = ActiveFedora::Base.find(parent_id)
      end
    end
  end
end
