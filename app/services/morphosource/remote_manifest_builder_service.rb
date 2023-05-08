# TODO: It would be better to build this in a programmatic way instead of hardcoding everything.
# See display_image in app/presenters/hyrax/iiif_manifest_presenter.rb as a start
module Morphosource
  class RemoteManifestBuilderService

    def initialize
      @iiif_version = "http://iiif.io/api/presentation/3/context.json"
      @json_context = "http://www.w3.org/ns/anno.jsonld"
    end

    def self.manifest_for(media)
      manifest_path = Rails.application.routes.url_helpers.manifest_hyrax_media_path(media)
      label = media.title
      file_set = media.file_sets.first
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
                      id: media.remote_manifest_url,
                      "type": "Image",
                      "width": file_set.width&.first&.to_i,
                      "height": file_set.height&.first&.to_i,
                      "format": "image/jpeg",
                      "label": {
                        "@none": [
                          label
                        ]
                      },
                      "service": [
                        {
                          id: media.remote_manifest_url.split('/info.json').first,
                          type: "ImageService3",
                          protocol: "http://iiif.io/api/image",
                          profile: "level2"
                        }
                      ]
                    },
                    "target": "#{manifest_path}/canvas/0"
                  }
                ]
              }
            ]
          }
        ]
      }
    end
  end
end