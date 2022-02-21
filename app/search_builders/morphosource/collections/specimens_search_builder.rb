module Morphosource
  module Collections
    class SpecimensSearchBuilder < Morphosource::Collections::ObjectsSearchBuilder
      include Hyrax::FilterByType

      self.default_processor_chain += [:return_selected_fields]

      def return_selected_fields(solr_parameters)
        if !@blacklight_params[:return_all_fields]
          solr_parameters[:fl] = 'id,has_model_ssim,title_tesim,taxonomy_tesim,date_uploaded_dtsi,record_source_ssim,idigbio_uuid_tesim'
        end
      end

      def models
        [BiologicalSpecimen]
      end

    end
  end
end
