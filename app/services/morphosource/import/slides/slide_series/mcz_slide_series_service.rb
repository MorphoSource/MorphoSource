module Morphosource
  module Import
    module Slides
      module SlideSeries
        class MczSlideSeriesService < SlideSeriesService

          include Morphosource::Import::SlideSeries::Slides::Mcz

          class_attribute :slide_class
          self.slide_class = Morphosource::Import::SlideSeries::Slides::MczSlide

          # Testing out eval w/ provider slide fields
          # def slides
          #   @json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"].select { |slide| slide["http://rs.tdwg.org/ac/terms/variant"] == "ac:BestQuality" }
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

          def collection_title
            ["#{@specimen.title.first} #{@json["scientificName"]}"]
          end

        end
      end
    end
  end
end
