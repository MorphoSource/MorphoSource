class Hyrax::BrowseController < ApplicationController
	include Hyrax::Browse::BrowseHelper

	with_themed_layout '1_column'      

	def categories
		render 'categories'
	end

	def physical_object_types
		get_media_po_type_info
    render 'physical_object_types'
	end

	def media_types_and_modalities
		get_media_type_and_modality_info
		render 'media_types_and_modalities'
	end
end
