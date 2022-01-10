module Importer
  class BatchObjectImporter

    attr_reader :attributes, :files_directory, :model, :update

    def self.call(model, attributes, files_directory = nil, update = false)
      new(model, attributes, files_directory, update).call
    end

    def initialize(model, attributes, files_directory = nil, update = false)
      @model = model
      @attributes = attributes
      @files_directory = files_directory
      @update = update
    end

    def call
      fc = factory_class(model)
      f = fc.new(attributes, files_directory, update)
      f.run
    end

    def factory_class(model)
      Factory.for(model.to_s)
    end

  end
end
