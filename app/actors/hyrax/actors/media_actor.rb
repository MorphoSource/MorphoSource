# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  module Actors
    class MediaActor < Hyrax::Actors::BaseActor
      include MorphosourceHelper
      include Morphosource::LinkedTeams::LinkedTeamsManagement

      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['keyword'] = split_keywords(env)
        add_team_access(env)
        super
      end

      def update(env)
        env.attributes['title'] = [ generated_title(env) ]
        env.attributes['keyword'] = split_keywords(env)
        add_team_access(env)
        super
      end

      def update_title(env)
        # update title with generated title after media is created (when media ID is available)
        if env.curation_concern.title != [ generated_title(env) ]
          env.curation_concern.title = [ generated_title(env) ]
          env.curation_concern.save
        end
        return true
      end

      def generated_title(env)
        attrs = env.attributes
        if attrs.key?('short_title') && (short_title = attrs['short_title']).present?
          # use custom title provided by user
          if attrs.key?('custom_title_case_sensitive')
            if attrs['custom_title_case_sensitive'] == ['1']
              return short_title.first
            end
          end
          return short_title.first.titleize
        else
          # use system generated title
          if attrs.key?('id')
            id = attrs['id'].presence || ''
          else
            id = env.curation_concern.id.presence || ''
          end

          if attrs.key?('part')
            part = attrs['part'].presence || ''
          else
            part = env.curation_concern.part.presence || ''
          end

          if attrs.key?('media_type')
            media_type = attrs['media_type']&.first.presence || ''
          else
            media_type = env.curation_concern.media_type&.first.presence || ''
          end

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

          # Final formatting and backup values
          parts = part.presence || ['Element unspecified']
          modality_abbrevs = ie_modality.map { |m| Morphosource::ModalitiesService.abbreviation(m) }

          parts.sort.join(', ').titleize +
            (media_type.presence ? ' [' + media_type.to_s + ']' : '') +
            (modality_abbrevs.presence ? ' [' + modality_abbrevs.join('/')+ ']' : ' [Etc]')
        end
      end

      private

      def add_team_access(env)
        return unless env.attributes[:work_parents_attributes] && env.attributes[:work_parents_attributes].present?

        find_parent(env)
        return if new_orgs.empty?

        add_organization_team_access([env.curation_concern])
      end

      def find_parent(env)
        parent_id = env.attributes[:work_parents_attributes].values.first['id']
        @parent = ActiveFedora::Base.find(parent_id)
      end

      def split_keywords(env)
        return unless env.attributes[:tags]
        tags = env.attributes[:tags]
        tags.split(',')
      end

      def new_physical_objects
        @parent.objects
      end
    end
  end
end
