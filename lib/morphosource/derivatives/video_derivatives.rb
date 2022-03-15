module Morphosource
	module Derivatives
		class VideoDerivatives < Hydra::Derivatives::Runner
    	def self.processor_class
      	::Morphosource::Derivatives::Processors::Video
    	end
		end
	end
end