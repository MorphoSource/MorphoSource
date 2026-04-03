# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  module Actors
    class ProcessingEventActor < Hyrax::Actors::BaseActor
      def create(env)
        env.attributes['title'] = [ generated_title(env) ]
        super
      end

      def update(env)
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
            work_parent = begin
              Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(wp['id']))
            rescue Valkyrie::Persistence::ObjectNotFoundError
              Morphosource::Works::Base.find(wp['id'])
            end
            work_parent_string = if work_parent.imaging_event?
              "IE#{wp['id']}"
            elsif work_parent.media?
              "M#{wp['id']}"
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
