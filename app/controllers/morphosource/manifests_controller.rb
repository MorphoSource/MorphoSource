require 'iiif_manifest'

module Morphosource
	class ManifestsController < ApplicationController
		class_attribute :iiif_manifest_builder
		self.iiif_manifest_builder = Hyrax::ManifestBuilderService.new(
			iiif_manifest_factory: ::IIIFManifest::V3::ManifestFactory
		)

		def show
			headers['Access-Control-Allow-Origin'] = '*'

		 	if params.include?(:id) && media_from_access_control(params[:id])
		 		json = iiif_manifest_builder.manifest_for(
		 			presenter: iiif_manifest_presenter(media_from_access_control(params[:id]))
		 		)

	      respond_to do |wants|
	        wants.json { render json: json }
	        wants.html { render json: json }
	      end
		 	else
		 		redirect_to '/'
		 	end
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