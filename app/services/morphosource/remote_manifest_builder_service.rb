module Morphosource
  class RemoteManifestBuilderService

    def initialize
      @iiif_version = "http://iiif.io/api/presentation/3/context.json"
      @json_context = "http://www.w3.org/ns/anno.jsonld"
    end

    def self.manifest_for(media)
      manifest_path = Rails.application.routes.url_helpers.manifest_hyrax_media_path(media)
      label = media.title
      byebug
      {
        "@context": [
          @json_context,
          @iiif_version
        ],
        "type": "Manifest",
        "id": manifest_path,
        "label": {
          "@none": [
            label
          ]
        },
        "items": [
          {
            "id": "#{manifest_path}/canvas/0",
            "type": "Canvas",
            "items": [
              {
                "id": "#{manifest_path}/canvas/0/annotationpage/0",
                "type": "AnnotationPage",
                "items": [
                  {
                    "id": "#{manifest_path}/canvas/0/annotation/0",
                    "type": "Annotation",
                    "motivation": "painting",
                    "body": {
                      "id": "#{manifest_path}/annotations/girder",
                      "type": "Image",
                      # "height"=>166,
                      # "width"=>192,
                      "format": "image/vnd.kitware.girder",
                      "label": {
                        "@none": [
                          label
                        ]
                      },
                      "service": [
                        {
                          "id": media.import_url,
                          "type": "GirderService",
                          "profile": "https://images.slide-atlas.org/api/v1"
                        }
                      ]
                    },
                    "target": "#{manifest_path}/canvas/0"
                  }
                ]
              }
            # ],
            ]
            # "width"=>192,
            # "height"=>166
          }
        ]
      }
    end
  end
end