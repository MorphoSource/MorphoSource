require 'date'

module Importer
  # Import a csv file with one work per row. The first row of the csv should be a
  # header row.
  class CSVImporter

    attr_reader :checksum_file, :depositor, :files_directory, :manifest_file, :model, :on_behalf_of

    # @param [String] manifest_file path to CSV file
    # @param [String] files_directory path, passed to factory constructor
    # @param [Hash] opts options for performing the import
    # @option opts [String] :checksum_file path to checksum file
    # @option opts [String] :depositor user_key of the User performing the deposit
    # @option opts [String, Class] :model the stringable first (Xxx) portion of the "XxxFactory" constant to be used
    #   for each row
    def initialize(manifest_file, files_directory, opts={})
      @manifest_file = manifest_file
      @files_directory = files_directory
      @checksum_file = opts.fetch(:checksum_file, nil)
      @depositor = opts.fetch(:depositor, nil)
      @model = opts.fetch(:model, 'Dataset')
    end

    # @return [Integer] count of objects created
    def import_all(delete_collection_ids=false)
      load_checksums if checksum_file
      count = 0
      parser.each do |attributes|
        attrs = attributes.merge(deposit_attributes)
        if attrs[:id]&.first && model.constantize.exists?(attrs[:id]&.first)
          next
        end
        import_batch_object(attrs, delete_collection_ids)
        count += 1
      end
      count
    end

    def import_batch_object(attributes, delete_collection_ids=false)
      puts("\n\n\n\n\nIMPORTING OBJECT WITH ID " + attributes[:id]&.first.to_s + " AT TIME " + DateTime.now.strftime("%d/%m/%Y %H:%M:%S") + "\n\n\n\n\n")
      attributes.delete(:collection_id) if delete_collection_ids
      BatchObjectImportJob.perform_now(model, attributes, files_directory)
    end

    def update_batch_object(attributes, delete_collection_ids=false)
      puts("\n\n\n\n\nUPDATING OBJECT WITH ID " + attributes[:id]&.first.to_s + " AT TIME " + DateTime.now.strftime("%d/%m/%Y %H:%M:%S") + "\n\n\n\n\n")
      attributes.delete(:collection_id) if delete_collection_ids
      BatchObjectImportJob.perform_now(model, attributes, files_directory, true)
    end

    private

    def deposit_attributes
      { depositor: depositor }
    end

    def parser
      CSVParser.new(manifest_file)
    end

    def load_checksums
      Checksum.import_data(checksum_file)
    end
  end
end
