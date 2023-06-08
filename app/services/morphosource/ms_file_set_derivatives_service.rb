module Morphosource
  # Responsible for creating and cleaning up the derivatives of a file_set with MS-specific methods
  class MsFileSetDerivativesService < Hyrax::FileSetDerivativesService
    def create_derivatives(filename)
      case mime_type
      when *file_set.class.pdf_mime_types             then create_pdf_derivatives(filename)
      when *file_set.class.office_document_mime_types then create_office_document_derivatives(filename)
      when *file_set.class.audio_mime_types           then create_audio_derivatives(filename)
      when *file_set.class.video_mime_types           then create_video_derivatives(filename)
      when *file_set.class.image_mime_types           then create_image_derivatives(filename)
      when *file_set.class.mesh_mime_types            then create_mesh_derivatives(filename)
      when *file_set.class.archive_mime_types         then create_archive_derivatives(filename)
      end
    end

    private

      def supported_mime_types
        file_set.class.pdf_mime_types +
          file_set.class.office_document_mime_types +
          file_set.class.audio_mime_types +
          file_set.class.video_mime_types +
          file_set.class.image_mime_types +
          file_set.class.mesh_mime_types +
          file_set.class.archive_mime_types
      end

      def create_video_derivatives(filename)
        Morphosource::Derivatives::VideoDerivatives.create(
          filename,
          outputs: [
            { label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
            { label: 'mp4', format: 'mp4', url: derivative_url('mp4') }
          ]
        )
      end

      def create_image_derivatives(filename)
        # We're asking for layer 0, becauase otherwise pyramidal tiffs flatten all the layers together into the thumbnail
        Morphosource::Derivatives::CroppedImageDerivatives.create(
          filename,
          outputs: [ { label: :thumbnail, url: derivative_url('thumbnail') } ]
        )
      end

      def create_mesh_derivatives(filename)
        parent_work = file_set.member_of&.first
        Morphosource::Derivatives::MeshDerivatives.create(
          filename,
          outputs: [ {
            label: :glb,
            format: 'glb',
            unit: parent_work&.unit&.first,
            url: derivative_url('glb')
          } ]
        )
      end

      def create_archive_derivatives(filename)
        parent_work = file_set.member_of&.first
        @errors = []

        # Create derivatives based on work media type
        if ( parent_work&.media_type&.first == 'SequentialSectionImageSeries' || parent_work&.media_type&.first == 'PhotogrammetryImageSeries' )
byebug
          create_thumbnail_from_series_image(filename)
        elsif parent_work&.media_type&.first == 'CTImageSeries'
byebug
          create_thumbnail_from_series_image(filename)
          create_3d_ct_image_series_derivative(
            filename,
            parent_work&.unit&.first,
            parent_work&.slice_thickness&.first,
            parent_work&.x_spacing&.first,
            parent_work&.y_spacing&.first,
            parent_work&.z_spacing&.first
          )
        elsif parent_work&.media_type&.first == 'Mesh'
byebug
          create_mesh_derivatives(filename)
        end

        # Handle errors
        if @errors.count == 1
          raise @errors.first
        elsif @errors.count > 1
          err0_trace = @errors[0].backtrace.present? ? " (#{@errors[0].backtrace.first})" : ""
          err1_trace = @errors[1].backtrace.present? ? " (#{@errors[1].backtrace.first})" : ""
          raise "Two errors were encountered generating derivatives for CT image series. Error 1 from 2D thumbnail derivative generation: #{@errors[0].message}#{err0_trace}. Error 2 from 3D asset derivative generation: #{@errors[1].message}#{err1_trace}."
        end
      end

      def create_thumbnail_from_series_image(filename)
byebug
#        begin
          # Pull out a single image as 2D thumbnail
          Morphosource::Derivatives::ImageSeriesCroppedImageDerivatives.create(
            filename,
            outputs: [ {
              label: :thumbnail,
              url: derivative_url('thumbnail')
            } ]
          )
#        rescue StandardError => e
#byebug
#          @errors << e
#        end
      end

      def create_3d_ct_image_series_derivative(filename, unit, slice_thickness, x_spacing, y_spacing, z_spacing)

#        begin
          # Create 3D derivative asset
byebug

          Morphosource::Derivatives::CTImageSeriesDerivatives.create(
            filename,
            outputs: [ { 
              label: :dcm,
              format: 'dcm',
              slice_thickness: slice_thickness,
              unit: unit,
              url: derivative_url('dcm'),
              x_spacing: x_spacing,
              y_spacing: y_spacing,
              z_spacing: z_spacing
            } ]
          )
#        rescue StandardError => e
#          @errors << e
#        end
      end
  end
end
