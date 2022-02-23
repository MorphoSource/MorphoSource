module Morphosource
  module Import
    module SlideSeries
      module Templates
        module Mcz

          #  file.bit_depth
          #  => []
          #  file.compression
          #  => ["JPEG"]
          #  2.6.6 :058 > file.color_space
          #  => ["YCbCr"]
          #  file.color_format
          #  => []
          #
          #  # color_depth
          #  2.6.6 :061 > file.bits_per_sample
          #  => ["8 8 8"]
          #

          # #  = z pixel spacing
          #   2.6.6 :070 > file.spacing_between_slices
          #  => ["0.58975"]
          #
          #  2.6.6 :074 > media.slice_thickness
          #  => ["17"]
          #

          TEMPLATE = {
            file_type: "BTF",
            file_type_extension: "btf",
            mime_type: "image/x-tiff-big",
            bits_per_sample: "8 8 8",
            compression: "JPEG",
            photometric_interpretation: "YCbCr",
            resolution: "0.25 um",
            source: "Bright Field",
            compress_option: "JPEG",
            compress_method: "Lossy",
            image_quality: "0.900000",
            make: "Huron Digital Pathology",
            camera_model_name: "TissueScope LE 120",
            orientation: "Horizontal",
            samples_per_pixel: "3",
            x_resololution: 40000,
            y_resolution: 40000,
            planar_configuration: "Chunky",
            resolution_unit: "cm"
            # software: "MACROscan 1.32"
          }

          # 1. Acquired on Huron LE-120 slide scanner
          # 2. Brightfield
          # 3. 24-bit RGB (8 bits per channel)
          # 4. 40x scan magnification
          # 5. pyramidal BigTIFF file format
          # 6. JPEG compression, 90% quality

          # I looked up the scan file dates corresponding to the different MACROscan software versions:
  #
  # 1.26: before Apr 23, 2018
  # 1.28: Apr 23, 2018 thru Jul 31, 2018
  # 1.31: Aug 1, 2018 thru Feb 15, 2019
  # 1.32: Feb 16, 2019 and later

        end
      end
    end
  end
end
