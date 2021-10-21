module Morphosource
  module Import
    class SlideSeriesService

      def initialize(service, resource_id, user_email)
        @service = service
        @resource_id = resource_id
        @manager = User.find_by(email: user_email)
      end

      def call
        if @service == "GBIF"
          import_gbif_slides
        end
        @collection
      end

      private

        def slide_series_collection(title)
          project_collection_type = Hyrax::CollectionType.where(title: "Project")
          collection = Collection.create(title: [title], collection_type_gid: project_collection_type.gid, depositor: @manager.ms_id)
          collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
          collection
        end

        def import_gbif_slides
          json = get_gbif_json
          slides = json["media"]
          @collection = slide_series_collection(json["scientificName"])
          slides.each do |slide|
            title = slide["title"]
            description = slide["description"]
            publisher = slide["publisher"]
            license = slide["license"]
            rightsHolder = slide["rightsHolder"]
            identifier = slide["identifier"]
            import_url = identifier.split("/tiles/", 2).first
            thumbnail_id = import_url.concat("/tiles/thumbnail")

            m = Media.new(title: [description], description: [description], license: [license], rights_holder: [rightsHolder], depositor: @manager.ms_id, publisher: [publisher], thumbnail_id: [identifier], )

            Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(Media.new, Ability.new(current_user), m.attributes))

            m.member_of_collections += [@collection]
            m.save!
          end
        end

        def get_gbif_json
          uri = "https://api.gbif.org/v1/occurrence/#{@resource_id}"
          response = RestClient.get uri
          JSON.parse(response.body)
        end
    end
  end
end
