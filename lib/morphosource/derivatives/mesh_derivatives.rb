module Morphosource
	module Derivatives
		class MeshDerivatives < Hydra::Derivatives::Runner
			# Adds format: 'glb' as the default to each of the directives
    	def self.transform_directives(options)
      	options.each do |directive|
        	directive.reverse_merge!(format: 'glb')
      	end
      	options
    	end

    	def self.processor_class
      	Processors::Mesh
    	end
		end
	end
end