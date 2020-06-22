module Ms1to2
	class UserImporter
    attr_accessor :user_csv, :vars_json_path, :volatile_vars_json_path, :update

    def initialize(input_path)
      @input_path = input_path
      @update = update
    end

    def call
      csv_importer = ::Importer::CSVImporter.new(
        File.join(@input_path, csvfile),
        '',
        { :model => "User" }
      )
      csv_importer.import_all_users
    end

    def csvfile
      'user.csv'
    end
	end
end