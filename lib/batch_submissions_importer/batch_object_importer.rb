module BatchSubmissionsImporter
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
      num_retries = 5
      retry_interval = 180
      fc = factory_class(model)
      f = fc.new(attributes, files_directory, update, preview_file)
      begin
        object = f.run          
      rescue Ldp::HttpError, Faraday::ConnectionFailed, Redis::CannotConnectError => e
        if num_retries > 0 && !object.present?
          puts "Exception in BatchObjectImporter: #{e.message}  Retrying in #{retry_interval} seconds..."
          num_retries -= 1
          sleep retry_interval
          retry
        else
          if !object.present?
            raise "Exception in BatchObjectImporter (max retries reached): #{e.message}"
          end
        end
      end
    end

    def factory_class(model)
      Factory.for(model.to_s)
    end

  end
end
