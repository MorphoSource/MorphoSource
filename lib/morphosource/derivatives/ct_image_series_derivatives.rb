module Morphosource
	module Derivatives
		class CTImageSeriesDerivatives < Hydra::Derivatives::Runner
			# Adds format: 'dcm' as the default to each of the directives
    	def self.transform_directives(options)
      	options.each do |directive|
        	directive.reverse_merge!(format: 'dcm')
      	end
      	options
    	end

    	def self.processor_class
      	Processors::CTImageSeries
    	end
		end
	end
end