module Morphosource
  module Import
    module SlideSeries
      module Slides
        module ExifData

          RESOLUTION_UNIT = {
            1 => ["None"],
            2 => ["In"],
            3 => ["Cm"]
          }

          COMPRESSION = {
            1 => ["Uncompressed"],
            2 => ["CCITT 1D"],
            3 => ["T4/Group 3 Fax"],
            4 => ["T6/Group 4 Fax"],
            5 => ["LZW"],
            6 => ["JPEG (old-style)"],
            7 => ["JPEG"],
            8 => ["Adobe Deflate"],
            9 => ["JBIG B&W"],
            10 => ["JBIG Color"],
            99 => ["JPEG"],
            262	=> ["Kodak 262"],
            32766	=> ["Next"],
            32767	=> ["Sony ARW Compressed"],
            32769	=> ["Packed RAW"],
            32770	=> ["Samsung SRW Compressed"],
            32771	=> ["CCIRLEW"],
            32772	=> ["Samsung SRW Compressed 2"],
            32773	=> ["PackBits"],
            32809	=> ["Thunderscan"],
            32867	=> ["Kodak KDC Compressed"],
            32895	=> ["IT8CTPAD"],
            32896	=> ["IT8LW"],
            32897	=> ["IT8MP"],
            32898	=> ["IT8BL"],
            32908	=> ["PixarFilm"],
            32909	=> ["PixarLog"],
            32946	=> ["Deflate"],
            32947	=> ["DCS"],
            33003	=> ["Aperio JPEG 2000 YCbCr"],
            33005	=> ["Aperio JPEG 2000 RGB"],
            34661	=> ["JBIG"],
            34676	=> ["SGILog"],
            34677	=> ["SGILog24"],
            34712	=> ["JPEG 2000"],
            34713	=> ["Nikon NEF Compressed"],
            34715	=> ["JBIG2 TIFF FX"],
            34718	=> ["Microsoft Document Imaging (MDI) Binary Level Codec"],
            34719	=> ["Microsoft Document Imaging (MDI) Progressive Transform Codec"],
            34720	=> ["Microsoft Document Imaging (MDI) Vector"],
            34887	=> ["ESRI Lerc"],
            34892	=> ["Lossy JPEG"],
            34925	=> ["LZMA2"],
            34926	=> ["Zstd"],
            34927	=> ["WebP"],
            34933	=> ["PNG"],
            34934	=> ["JPEG XR"],
            65000	=> ["Kodak DCR Compressed"],
            65535	=> ["Pentax PEF Compressed"]
          }

          PHOTOMETRIC_INTERPRETATION = {
            0 => ["WhiteIsZero"],
            1 => ["BlackIsZero"],
            2 => ["RGB"],
            3 => ["RGB Palette"],
            4 => ["Transparency Mask"],
            5 => ["CMYK"],
            6 => ["YCbCr"],
            8 => ["CIELab"],
            9 => ["ICCLab"],
            10 => ["ITULab"],
            32803 => ["Color Filter Array"],
            32844 => ["Pixar LogL"],
            32845 => ["Pixar LogLuv"],
            32892 => ["Sequential Color Filter"],
            34892 => ["Linear Raw"],
            51177 => ["Depth Map"],
            52527 => ["Semantic Mask"]
          }

        end
      end
    end
  end
end