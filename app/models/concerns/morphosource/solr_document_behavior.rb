module Morphosource
	module SolrDocumentBehavior
		extend ActiveSupport::Concern
		include Morphosource::Works::MimeTypes
	end
end