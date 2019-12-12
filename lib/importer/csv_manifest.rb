module Importer
  class CSVManifest
    include ActiveModel::Validations

    def self.controlled_vocabularies
      ["licenses", "rights_statements", "resource_types"]
    end

    def self.controlled_vocabularies_headings
      @controlled_vocabs_headings ||= controlled_vocabularies.map(&:singularize).map(&:to_sym)
    end

    def self.controlled_vocabularies_values
      @controlled_vocabs_values ||=
              controlled_vocabularies.inject({}) do |hash, vocab|
                hash.update(vocab => Qa::Authorities::Local.subauthority_for(vocab).all.map { |entry| entry['id'] })
              end
    end

    def self.controlled_vocabulary_values(vocab_name)
      controlled_vocabularies_values[vocab_name]
    end

    def self.valid_headers
      Dataset.attribute_names + %w(collection_id parent_ark visibility file)
    end

    attr_reader :files_directory, :manifest_file

    validate :metadata_headers
    validate :controlled_vocabulary_values
    validate :files_must_exist
    validate :on_behalf_of_users_must_exist

    def initialize(manifest_file, files_directory)
      @manifest_file = manifest_file
      @files_directory = files_directory
    end

    def parser
      @parser ||= CSVParser.new(manifest_file)
    end

    def metadata_headers
      parser.headers.each do |header|
        unless self.class.valid_headers.include?(header)
          errors.add(:base, I18n.t('rdr.batch_import.invalid_metadata_header', header: header))
        end
      end
    end

    def controlled_vocabulary_values
      parser.each do |attributes|
        attributes.each do |heading, values|
          if self.class.controlled_vocabularies_headings.include?(heading)
            validate_attribute_values(heading, values)
          end
        end
      end
    end

    def validate_attribute_values(heading, values)
      values.each do |value|
        validate_attribute_value(heading, value)
      end
    end

    def validate_attribute_value(heading, value)
      vocab = heading.to_s.pluralize
      unless self.class.controlled_vocabulary_values(vocab).include?(value)
        errors.add(heading, I18n.t('rdr.batch_import.invalid_metadata_value', field: heading, value: value))
      end
    end

    def files_must_exist
      parser.each do |attributes|
        validate_files attributes[:file] if attributes[:file]
      end
    end

    def validate_files(files)
      files.each do |file|
        validate_file(file)
      end
    end

    def validate_file(file)
      unless File.exist?(File.join(files_directory, file))
        errors.add(:files, I18n.t('rdr.batch_import.nonexistent_file', path: File.join(files_directory, file)))
      end
    end

    def on_behalf_of_users_must_exist
      parser.each do |attributes|
        users_must_exist attributes[:on_behalf_of] if attributes[:on_behalf_of]
      end
    end

    def users_must_exist(user_keys)
      user_keys.each do |ukey|
        validate_user_exists(ukey)
      end
    end

    def validate_user_exists(user_key)
      unless User.find_by_user_key(user_key)
        errors.add(:on_behalf_of, I18n.t('rdr.batch_import.nonexistent_user', user_key: user_key))
      end
    end

  end
end
