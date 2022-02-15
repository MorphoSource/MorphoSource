module Morphosource::Derivatives::Processors
  class Video < Hydra::Derivatives::Processors::Video::Processor
    def encode_file(file_suffix, options)
      temp_file_name = output_file(file_suffix)
      self.class.encode(source_path, options, temp_file_name)
      output_file_service.call(File.open(temp_file_name, 'rb'), directives)
      File.unlink(temp_file_name) if File.exists?(temp_file_name)
    end
  end
end