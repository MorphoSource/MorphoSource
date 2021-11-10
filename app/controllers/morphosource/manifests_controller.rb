require 'iiif_manifest'

module Morphosource
  class ManifestsController < ApplicationController
    class_attribute :iiif_manifest_builder
    self.iiif_manifest_builder = Hyrax::ManifestBuilderService.new(
      iiif_manifest_factory: ::IIIFManifest::V3::ManifestFactory
    )

    # def show
    #   # byebug
    #   headers['Access-Control-Allow-Origin'] = '*'

        # json = {"@context"=>[
        #   "http://www.w3.org/ns/anno.jsonld",
        #   "http://iiif.io/api/presentation/3/context.json"
        #   ],
        #   "type"=>"Manifest",
        #   "id"=>"http://slideatlas-test-manifests.netlify.app/collection/girder/index.json",
        #   "label"=>{"@none"=>["Element Unspecified [Image] [Photogram]"]}, "metadata"=>nil,
        #   "rendering"=>[],
        #   "items"=>[
        #     {
        #       "type"=>"Canvas",
        #       "id"=>"http://slideatlas-test-manifests.netlify.app/collection/girder/index.json/canvas/0",
        #       "label"=>{"@none"=>["Screenshot_2018-10-04_15.07.16.png"]}, "items"=>[
        #         {"type"=>"AnnotationPage",
        #           "id"=>"http://slideatlas-test-manifests.netlify.app/collection/girder/index.json/canvas/0/annotationpage/0",
        #           "items"=>[
        #             {"type"=>"Annotation",
        #               "motivation"=>"painting",
        #               "body"=>{
        #                 "id"=>"http://slideatlas-test-manifests.netlify.app/collection/girder/index.json/annotations/girder",
        #                 "type"=>"Image",
        #                 "format"=>"image/vnd.kitware.girder",
        #                 "service"=>[
        #                   {
        #                     "id"=>"http://images.slide-atlas.org/api/v1/item/5bb27c0070aaa9066ecd0a0f/",
        #                     "profile"=>"https://images.slide-atlas.org/api/v1",
        #                     "type"=>"GirderService"}]}, "target"=>"http://slideatlas-test-manifests.netlify.app/collection/girder/index.json/canvas/0"}]}]}]}

      #   uri = "http://slideatlas-test-manifests.netlify.app/collection/girder/index.json"
      #   # byebug
      #   # uri = "https://wellcomelibrary.org/iiif/b18035723/manifest"
      #   # uri = "https://slideatlas-test-manifests.netlify.app/collection/girder/multi-image.json"
      #   response = RestClient.get uri
      #   json = JSON.parse(response.body)
      #   # byebug
      #   respond_to do |wants|
      #     wants.json { render json: json }
      #     wants.html { render json: json }
      #   end
      # end
    #    else
    #      redirect_to '/'
    #    end
    # rescue CanCan::AccessDenied
    #   flash[:alert] = 'You are not authorized to access this resource.'
    #   redirect_to '/'
    # end

    def show
      # byebug
      headers['Access-Control-Allow-Origin'] = '*'

       if params.include?(:id) && (m = media_from_access_control(params[:id]))
        authorize! :read, m.id

        #manifest_builder = <Hyrax::ManifestBuilderService:0x00005649cad00768 @manifest_factory=IIIFManifest::V3::ManifestFactory>

        # iiif_manifest_presenter.class = Hyrax::IiifManifestPresenter

         json = iiif_manifest_builder.manifest_for(
           presenter: iiif_manifest_presenter(m)
         )

         # byebug

        respond_to do |wants|
          wants.json { render json: json }
          wants.html { render json: json }
        end
       else
         redirect_to '/'
       end
    rescue CanCan::AccessDenied
      flash[:alert] = 'You are not authorized to access this resource.'
      redirect_to '/'
    end

    private
      def media_from_access_control(access_control_id)
        Media.where(accessControl_ssim: access_control_id)&.first
      end

      def iiif_manifest_builder
        self.class.iiif_manifest_builder
      end

      def iiif_manifest_presenter(work)
        Hyrax::IiifManifestPresenter.new(work).tap do |p|
          p.hostname = request.base_url
          p.ability = current_ability
        end
      end
  end
end
