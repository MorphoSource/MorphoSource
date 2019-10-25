module Ms1to2
  class Normalizer
    attr_accessor :input_path, :output_path, :ms1_input_data, :ms2_output_data

    def initialize(input_path, output_path)
      @input_path = input_path
      @output_path = output_path
      @ms1_input_data = "Ms1to2::Ms1InputData".constantize.new(input_path)
      @ms2_output_data = "Ms1to2::Ms2OutputData".constantize.new(output_path)
    end

    def call
      models.each do |m|
        puts(m)
        factory = "Ms1to2::Factories::#{m}Factory".constantize
        factory.new(ms1_input_data, ms2_output_data).run
      end
      ms2_output_data.export_data
    end

    def models
      [:Collection, :Organization, :Device, :Taxonomy, :BiologicalSpecimen, :Media]
    end
  end
end