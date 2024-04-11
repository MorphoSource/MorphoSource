module Morphosource::Derivatives
  class Img2dcmError < RuntimeError
  end

  class Img2dcm < DerivativeTool
    attr_reader :source_path, :out_path, :x, :y, :z, :thickness, :file_path, :file_out_path
    def initialize(source_path, out_path, x=nil, y=nil, z=nil, thickness=nil)
      @source_path = source_path
      @out_path = out_path
      @x = x
      @y = y
      @z = z
      @thickness = thickness
    end

    def call
      unless Dir.exists?(source_path)
        raise Morphosource::Derivatives::Img2dcmError.new("Source directory: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    protected

    def internal_call
      files = (Dir.entries(source_path).select {|f| acceptable_file? f }).sort
      files.each do |f|
        @file_path = File.join(source_path, f)
        @file_out_path = File.join(out_path, File.basename(f, '.jpg')+'.dcm')
        output = process_file
        post_process(output)
      end
    end

    def acceptable_file?(f)
      File.file?(File.join(source_path, f)) && File.extname(f).downcase == '.jpg'
    end

    def command
      "img2dcm " +
        ( x && y ? "-k 'PixelSpacing=" + x.to_s + "\\" + y.to_s + "' " : "" ) +
        ( z ? "-k 'SpacingBetweenSlices=" + z.to_s + "' " : "") + 
        ( thickness ? "-k 'SliceThickness=" + thickness.to_s + "' " : "") + 
        "-sef #{File.join(Rails.root, 'lib/assets/template.dcm')} '#{file_path}' '#{file_out_path}'"
    end

    # Check for produced derivative file, otherwise raise img2dcm response as error
    def post_process(raw_output)
      if !File.exists?(file_out_path) || (File.size(file_out_path) == 0)
        raise Morphosource::Derivatives::Img2dcmError.new("File not successfully created by derivative tool.\nTool command: \"#{command}\"\nTool output:\n\"#{raw_output}\"")
      end
    end
  end
end
