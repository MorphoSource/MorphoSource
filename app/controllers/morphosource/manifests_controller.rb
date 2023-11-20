require 'iiif_manifest'

module Morphosource
  class ManifestsController < ApplicationController
    include Morphosource::RestApiBehavior
    include Morphosource::TemporaryAccess::TemporaryAccessControllerBehavior

    before_action :authenticate_api_key_required, only: :get_manifest_link
    before_action :set_access_control_headers

    class_attribute :iiif_manifest_builder
    class_attribute :remote_manifest_builder

    self.iiif_manifest_builder = Hyrax::ManifestBuilderService.new(
      iiif_manifest_factory: ::IIIFManifest::V3::ManifestFactory
    )
    self.remote_manifest_builder = Morphosource::RemoteManifestBuilderService
    self.temporary_access_link_class = TemporaryMediaAccessLink

    def show
      if params.include?(:id) && (m = media_from_access_control(params[:id]))
        authorize_media_with_temporary_link m.id
        authorize! :read, m.id

        if m.has_remote_manifest?
          json = remote_manifest_builder.manifest_for(m)
        else
          json = iiif_manifest_builder.manifest_for(
            presenter: iiif_manifest_presenter(m)
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

        response = {
          media: {
            id: m.id,
            manifest_url: main_app.manifest_url(m.access_control_id.first)
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