module Morphosource
  module Import
    class MczSlideSeriesService < SlideSeriesService

      include Morphosource::Import::SlideSeries::Slides::Mcz

      class_attribute :slide_class
      self.slide_class = Morphosource::Import::SlideSeries::Slides::MczSlide

      def fetch_json
        @json = gbif_json
      end

      def slides
        @json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"].select { |slide| slide["http://rs.tdwg.org/ac/terms/variant"] == "ac:Thumbnail" }
      end

      def collection_title
        @json["scientificName"]
      end

      private

        def gbif_json
          uri = "https://api.gbif.org/v1/occurrence/#{@resource_id}"
          response = RestClient.get uri
          JSON.parse(response.body)
        end

    end
  end
end
