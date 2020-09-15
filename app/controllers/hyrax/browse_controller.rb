class Hyrax::BrowseController < ApplicationController

	with_themed_layout 'morphosource_1_column'      

	def physical_object_types
    render 'physical_object_types'
	end

end
