module Hydra::Works
  class Crc32CharacterizationService < CharacterizationService
    attr_accessor :crc32_calculator

    def characterize
      content = source_to_content
      crc32 = calculate_crc32(content)
      object.send('crc32=', crc32)
    end

    protected

      def calculate_crc32(content)
        if content.respond_to?(:eof?) # Is this an appropriate IO object?
          ZipTricks::StreamCRC32.from_io(content)
        elsif content.class == Hydra::PCDM::File # Is this a Hyrax original_file?
          crc_from_pcdm_file(content)
        elsif content.is_a? String
          crc_from_string(content)
        else
          raise "Unrecognized content type for calculating CRC32"
        end 
      end

      def crc_from_pcdm_file(content)
        # Use Streambody to get CRC32 
        content.stream.each { |chunk| crc32_calculator << chunk }
        crc32_calculator.to_i
      end

      def crc_from_string(content)
        crc32_calculator << content
        crc32_calculator.to_i
      end

      def crc32_calculator
        @crc32_calculator ||= ZipTricks::StreamCRC32.new
      end
  end
end