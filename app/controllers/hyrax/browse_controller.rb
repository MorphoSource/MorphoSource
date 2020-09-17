class Hyrax::BrowseController < ApplicationController
	include Hyrax::Browse::BrowseHelper

	with_themed_layout 'morphosource_1_column'      

	def physical_object_types
    render 'physical_object_types'
	end

	def media_types_and_modalities
		get_media_type_info
		render 'media_types_and_modalities'
	end
end
