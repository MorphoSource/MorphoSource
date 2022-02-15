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
        Morphosource::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
                                                              { label: 'webm', format: 'webm', url: derivative_url('webm') },
                                                              { label: 'mp4', format: 'mp4', url: derivative_url('mp4') }])
      end

      def create_image_derivatives(filename)
        # We're asking for layer 0, becauase otherwise pyramidal tiffs flatten all the layers together into the thumbnail
        Morphosource::Derivatives::CroppedImageDerivatives.create(filename,
                                                  outputs: [{ label: :thumbnail,
                                                              url: derivative_url('thumbnail') }])
      end

      def create_mesh_derivatives(filename)
        Morphosource::Derivatives::MeshDerivatives.create(filename,
                                                          outputs: [{ label: :glb,
                                                                      format: 'glb',
                                                                      unit: file_set.member_of&.first&.unit&.first,
                                                                      url: derivative_url('glb')}])
      end

      def create_archive_derivatives(filename)
        if file_set.member_of.first.media_type.first == 'CTImageSeries'
          Morphosource::Derivatives::CTImageSeriesDerivatives.create(filename,
                                                                     outputs: [{ label: :dcm,
                                                                                 format: 'dcm',
                                                                                 slice_thickness: file_set.member_of.first.slice_thickness.first,
                                                                                 unit: file_set.member_of.first.unit.first,
                                                                                 url: derivative_url('dcm'),
                                                                                 x_spacing: file_set.member_of.first.x_spacing.first,
                                                                                 y_spacing: file_set.member_of.first.y_spacing.first,
                                                                                 z_spacing: file_set.member_of.first.z_spacing.first
                                                                              }])
        elsif file_set.member_of.first.media_type.first == 'Mesh'
           Morphosource::Derivatives::MeshDerivatives.create(filename,
                                                             outputs: [{ label: :glb,
                                                                         format: 'glb',
                                                                         unit: file_set.member_of.first.unit.first,
                                                                         url: derivative_url('glb')}])
        end
      end
  end
end
