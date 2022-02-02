module Morphosource
  module Collections
    class MediaProjectsSearchBuilder < Morphosource::Collections::MediaSearchBuilder

      def return_selected_fields(solr_parameters)
        solr_parameters[:fl] = 'member_of_collection_ids_ssim'
      end
    end
  end
end
