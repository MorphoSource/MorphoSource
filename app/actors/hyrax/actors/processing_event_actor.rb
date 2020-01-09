# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  module Actors
    class ProcessingEventActor < Hyrax::Actors::BaseActor
      def create(env)
byebug
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
byebug
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def generated_title(env)
        # M<media parent hyrax ID> Processing Event (<date created>)
        # For media parent fields, blank if no value
        # For date created, if no value should be “(No Event Date)”
        attrs = env.attributes
        work_parents = ''
        if attrs['work_parents_attributes'].present?
          attrs['work_parents_attributes'].each do |key, wp|
            work_parent = Morphosource::Works::Base.find(wp['id'])
            work_parent_string = case work_parent.class.to_s
              when 'Media'
                "M#{wp['id']}"
              when 'ImagingEvent'
                "IE#{wp['id']}"
            end
            work_parents += "#{work_parent_string} "
          end
        end
        date_created = attrs['date_created'].present? ? attrs['date_created'].first : 'No Event Date'
        title = "#{work_parents}Processing Event (#{date_created})"
        title
      end
    end
  end
end
