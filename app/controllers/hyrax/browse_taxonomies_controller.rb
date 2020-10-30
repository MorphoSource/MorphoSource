class Hyrax::BrowseTaxonomiesController < ApplicationController
	with_themed_layout 'morphosource_1_column' 

	def index
    @higher_names = taxonomy_names
    @names = taxonomy_browse_service.call(taxonomy_names)
    @specimen_taxonomy_term = taxonomy_names.present? ? taxonomy_names.last[:name] : nil
    @specimens = taxonomy_browse_service.taxonomy_specimens(@specimen_taxonomy_term)

    respond_to do |format|
      format.html  # index.html.erb
      format.js # index.js.erb
    end
	end

	private
		def taxonomy_browse_service
      Morphosource::TaxonomyBrowseService
    end

    def taxonomy_names
      @taxonomy_names ||= taxonomy_params.to_h.map do |p, v| 
        { 
          name: v, 
          rank: p, 
          count: taxonomy_browse_service.count([name: v, rank: p]),
          specimen_count: taxonomy_browse_service.taxonomy_specimens_count(v)
        }
      end
    end

    def taxonomy_params
      params.permit(
        :kingdom,
        :phylum,
        :class,
        :order,
        :family,
        :genus,
        :species
      )
    end

end
