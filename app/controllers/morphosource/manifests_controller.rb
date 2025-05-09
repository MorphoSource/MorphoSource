require 'iiif_manifest'

module Morphosource
  class ManifestsController < ApplicationController
    include Morphosource::RestApiBehavior
    include Morphosource::TemporaryAccess::TemporaryAccessControllerBehavior

    before_action :authenticate_api_key_required, only: :get_manifest_link
    before_action :set_access_control_headers

    class_attribute :iiif_manifest_builder
    class_attribute :iiif_manifest_builder_v4
    class_attribute :remote_manifest_builder

    self.iiif_manifest_builder = Hyrax::ManifestBuilderService.new(
      iiif_manifest_factory: ::IIIFManifest::V3::ManifestFactory
    )
    self.iiif_manifest_builder_v4 = Hyrax::ManifestBuilderService.new(
      iiif_manifest_factory: ::IIIFManifest::V4::ManifestFactory
    )
    self.remote_manifest_builder = Morphosource::RemoteManifestBuilderService
    self.temporary_access_link_class = TemporaryMediaAccessLink

     # Show IIIF Presentation API manifest
    def show
      if params.include?(:id) && (m = media_from_access_control(params[:id]))
        authorize_media_with_temporary_link m.id
        authorize! :read, m.id

        builder = version == 'v4' ? iiif_manifest_builder_v4 : iiif_manifest_builder

        if m.has_remote_manifest?
          json = remote_manifest_builder.manifest_for(m)
        else
          json = builder.manifest_for(
            presenter: version == 'v4' ? iiif_manifest_presenter_v4(m) : iiif_manifest_presenter(m)
          )
        end

        respond_to do |format|
          format.json { render json: json }
          format.html { render json: json }
        end
      else
        raise CanCan::AccessDenied
      end
    end

    def get_manifest_link
      if (
        params.include?(:id) && 
        Media.exists?(params[:id]) && 
        (m = SolrDocument.find(params[:id])) && 
        m.access_control_id&.first.present?
      )
        authorize! :read, m.id

        if params[:version]&.downcase == 'v3'
          manifest_url = main_app.manifest_url(m.access_control_id.first)
        elsif params[:version]&.downcase == 'v4'
          manifest_url = main_app.manifest_v4_url(m.access_control_id.first)
        else 
          raise CanCan::AccessDenied
        end

        response = {
          media: {
            id: m.id,
            manifest_url: manifest_url
          }
        }

        respond_to do |format|
          format.json { render json: { response: response } }
          format.html { render json: { response: response } }
        end
      else
        raise CanCan::AccessDenied
      end
    end

    private
      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
      end

      def media_from_access_control(access_control_id)
        SolrDocument.where({ "accessControl_ssim" => access_control_id, "has_model_ssim" => "Media" })&.first
      end

      def iiif_manifest_builder
        self.class.iiif_manifest_builder
      end

      def iiif_manifest_builder_v4
        self.class.iiif_manifest_builder_v4
      end

      def iiif_manifest_presenter(work)
        Hyrax::IiifManifestPresenter.new(work).tap do |p|
          p.ability = current_ability
          p.access_control_id = params[:id]
          p.hostname = request.base_url
        end
      end

      def iiif_manifest_presenter_v4(work)
        Hyrax::IiifManifestV4Presenter.new(work).tap do |p|
          p.ability = current_ability
          p.access_control_id = params[:id]
          p.hostname = request.base_url
        end
      end

      def version
        params[:version]&.downcase == 'v4' ? 'v4' : 'v3'
      end
  end
end