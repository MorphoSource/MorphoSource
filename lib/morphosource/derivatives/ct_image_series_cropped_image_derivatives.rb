module Morphosource
	module Derivatives
		class CTImageSeriesCroppedImageDerivatives < Hydra::Derivatives::Runner
			# Adds format: 'jpg' as the default to each of the directives
    	def self.transform_directives(options)
      	options.each do |directive|
        	directive.reverse_merge!(format: 'jpg')
          directive.reverse_merge!(size: '300x300^')
          directive.reverse_merge!(crop: 'true')
          directive.reverse_merge!(crop_size: '300x300+0+0')
          directive.reverse_merge!(quality: '90')
          directive.reverse_merge!(layer: 0)
      	end
      	options
    	end

    	def self.processor_class
      	::Morphosource::Derivatives::Processors::CTImageSeriesCroppedImage
    	end
		end
	end
end