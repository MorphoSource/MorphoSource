module Importer
  class BatchObjectImporter

    attr_reader :attributes, :files_directory, :model, :update, :preview_file

    def self.call(model, attributes, files_directory = nil, update = false, preview_file = nil)
      new(model, attributes, files_directory, update, preview_file).call
    end

    def initialize(model, attributes, files_directory = nil, update = false, preview_file = nil)
      @model = model
      @attributes = attributes
      @files_directory = files_directory
      @update = update
      @preview_file = preview_file
    end

    def call
      fc = factory_class(model)
      f = fc.new(attributes, files_directory, update, preview_file)
      f.run
    end

    def factory_class(model)
      Factory.for(model.to_s)
    end

  end
end
