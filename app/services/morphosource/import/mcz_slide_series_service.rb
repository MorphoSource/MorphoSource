module Morphosource
  module Import
    class MczSlideSeriesService < SlideSeriesService

      include Morphosource::Import::SlideSeries::Slides::Mcz

      class_attribute :slide_class
      self.slide_class = Morphosource::Import::SlideSeries::Slides::MczSlide

      # def fetch_json
      #   gbif_json
      # end

      def slides
        @json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"].select { |slide| slide["http://rs.tdwg.org/ac/terms/variant"] == "ac:BestQuality" }
      end

      def collection_title
        @json["scientificName"].present? ? [@json["identifier"] + ' ' + @json["scientificName"]] : [@json["identifier"] + ' ' + @specimen.title.first + ' ' + @specimen.taxonomies.first.title.first]
      end



      def collection_related_url
        [occurrence_uri, mczbase_specimen_uri]
      end

      def mczbase_specimen_uri
        @json["references"]
      end

      # def organization
      #   @organization ||= Organization.where(title: ["MCZ Special Collections"]).first
      # end

      def device
        first_slide_iiif = slides.first["http://rs.tdwg.org/ac/terms/accessURI"].split('/full/').first.concat("/info.json")
        first_slide_device = JSON.parse((RestClient.get first_slide_iiif).body).dig("exif","fields","Model")
        if first_slide_device.present?
          @device ||= @organization.devices.detect { |d| d.title == Array(first_slide_device) }
        else
          @device ||= @organization.devices.detect { |d| d.title == Array("TissueScope LE 120") }
        end
      end

      # def gbif_key
      #   @json["taxonKey"]
      # end



    end
  end
end
