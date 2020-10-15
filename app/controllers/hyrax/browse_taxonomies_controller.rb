class Hyrax::BrowseTaxonomiesController < ApplicationController
	with_themed_layout 'morphosource_2_columns'   

	def index
    @taxonomy_params = taxonomy_params.to_h
    @names = taxonomy_browse_service.call(taxonomy_names)
    
    respond_to do |format|
      format.html  # index.html.erb
      format.js # index.js.erb
    end
	end

  def children
    response_object = {
      path: taxonomy_names,
      children: taxonomy_browse_service.call(taxonomy_names)
    }
    render :json => response_object
  end

	private 
		def taxonomy_browse_service
      Morphosource::TaxonomyBrowseService
    end

    def taxonomy_names
      taxonomy_params.to_h.map { |p, v| { name: v, rank: p } }
    end

    def taxonomy_params
      params.permit(
        :kingdom,
        :phylum,
        :class,
        :order,
        :family,
        :genus
      )
    end

end
