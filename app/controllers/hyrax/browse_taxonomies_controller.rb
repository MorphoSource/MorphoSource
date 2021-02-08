class Hyrax::BrowseTaxonomiesController < ApplicationController
	with_themed_layout 'morphosource_1_column' 

	def index
    @higher_names = taxonomy_names
    @names = taxonomy_browse_service.call(taxonomy_names)
    if taxonomy_names.present?
      terminal_names = [ taxonomy_names.last ]
      terminal_names << taxonomy_names.find { |n| n[:rank] == 'genus' } if taxonomy_names.last[:rank] == 'species'
      terminal_names.compact!
    else
      terminal_names = [name: nil, rank: nil]
    end
    @specimens = taxonomy_browse_service.taxonomy_specimens(terminal_names)

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
        if p == 'species' && taxonomy_params.to_h['genus'].present?
          names_to_count = [ { name: v, rank: p}, {name: taxonomy_params.to_h['genus'], rank: 'genus'} ]
        else
          names_to_count = [name: v, rank: p]
        end
        { 
          name: v, 
          rank: p, 
          count: taxonomy_browse_service.count(names_to_count),
          specimen_count: taxonomy_browse_service.taxonomy_specimens_count(names_to_count)
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
