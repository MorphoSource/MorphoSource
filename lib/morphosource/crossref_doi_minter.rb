require 'nokogiri'
require 'erb'
require 'ostruct'
require 'rest-client'
require 'securerandom'

module Morphosource
  module CrossrefDoiMinter
    extend ActiveSupport::Autoload

    SUBMISSION_PATH = 'servlet/deposit'
    @@xsd_schemas = {}

    # Used to transform params hash into binding for ERB template rendering
    class CrossrefMetadataTemplate < OpenStruct
      def render(erb_template)
        ERB.new(erb_template).result(binding)
      end
    end

    # Used to transform XML string into an IO object suitable for RestClient multipart POST
    def self.string_to_file(string, filename="file_#{rand 100000}", type=MIME::Types.type_for("xml").first.content_type)
      file = StringIO.new(string)

      file.instance_variable_set(:@path, filename)
      def file.path
        @path
      end
      file.instance_variable_set(:@type, type)
      def file.content_type
        @type
      end

      return file
    end

    # See: https://www.crossref.org/education/content-registration/crossrefs-metadata-deposit-schema/metadata-deposit-schema-4-4-2/
    def self.validate_metadata_deposit_xml(input_xml, model:)
      # memoized XSD parsing, since parsing the XSD is somewhat time-consuming
      # Cache schemas by path because Media and MediaList deposits use different
      # Crossref schema versions.
      current_schema_path = schema_path(model)
      xsd_schema = (@@xsd_schemas[current_schema_path.to_s] ||= Nokogiri::XML::Schema(File.open(current_schema_path)))
      validation_errors = xsd_schema.validate(Nokogiri::XML(input_xml))
      if validation_errors.empty?
        return input_xml
      else
        raise "Error(s) validating Crossref metadata deposit XML: #{validation_errors.first.message}"
      end
    end

    def self.identifier_to_doi(identifier, model:)
      "#{ENV['CROSSREF_DOI_SHOULDER']}/#{type_letter(model)}#{identifier.sub(/^0*/,'')}"
    end

    # Required keys in params hash:
    # - title
    # - url
    # - resource_type
    # Also, either organization must be present OR both author_first and author_last must be present
    def self.generate_metadata_deposit_xml(identifier, params={}, model:)
      doi = identifier_to_doi(identifier, model: model)

      # clean params and add additional params as necessary

      # if author_first or author_last are > 60 characters, truncate
      if params['author_first'] && params['author_first'].length > 60
        params['author_first'] = params['author_first'].truncate(60)
      end
      if params['author_last'] && params['author_last'].length > 60
        params['author_last'] = params['author_last'].truncate(60)
      end
      if params['organization'] && params['organization'].length > 511
        params['organization'] = params['organization'].truncate(511)
      end

      # set timestamp and publication_year if not passed in
      params.reverse_merge!({'timestamp' => Time.now.to_i, 'publication_year' => Time.now.year})
      # always set doi_batch_id and doi
      params.merge!({'doi_batch_id' => SecureRandom.uuid, 'doi' => doi})

      required_params(model).each do |required_param|
        if params[required_param].blank?
          raise "CrossrefDoiMinter.generate_metadata_deposit_xml call missing required parameter: #{required_param}"
        else
          params[required_param] = params[required_param].to_s.encode(xml: :text)
        end
      end

      if params['organization'].blank? && (params['author_first'].blank? || params['author_last'].blank?)
        raise "CrossrefDoiMinter.generate_metadata_deposit_xml call missing required parameter: organization OR author_first and author_last"
      end

      rendered_xml = CrossrefMetadataTemplate.new(params).render(File.new(template_path(model)).read)
      Rails.logger.info("CrossrefDoiMinter.generate_metadata_deposit_xml rendered deposit XML: #{rendered_xml}")
      return validate_metadata_deposit_xml(rendered_xml, model: model)
    end

    def self.mint_doi(identifier, metadata_params={})
      model = SolrDocument.find(identifier)["has_model_ssim"]&.first
      %w{username password shoulder url}.each do |doi_param|
        environment_param = "CROSSREF_DOI_#{doi_param.upcase}"
        if ENV[environment_param].blank?
          raise "Required environment variable for Crossref DOI minting is missing: #{environment_param}"
          nil
        end
      end
      submission_url = "#{ENV['CROSSREF_DOI_URL']}/#{SUBMISSION_PATH}"
      login_id = ENV['CROSSREF_DOI_USERNAME']
      login_passwd = ENV['CROSSREF_DOI_PASSWORD']
      deposit_xml = generate_metadata_deposit_xml(identifier, metadata_params, model: model)
      # See: https://www.crossref.org/education/member-setup/direct-deposit-xml/https-post/
      begin
        submission_response = RestClient.post(submission_url, multipart: true, fname: string_to_file(deposit_xml), login_id: login_id, login_passwd: login_passwd, headers: {content_type: "multipart/form-data"})
        Rails.logger.info("CrossrefDoiMinter.mint_doi submission response: #{submission_response.body}")
      rescue RestClient::ExceptionWithResponse => exception
        exception
      end
      identifier_to_doi(identifier, model: model)
    end

    # model type methods

    TYPE_CONFIG = {
      "Media" => {
        required_params:  %w[doi_batch_id title doi url resource_type timestamp publication_year],
        schema_path:      Rails.root.join('data','xsds','crossref4.4.2.xsd'),
        template_path:    Rails.root.join("data", "xmls", "doi.xml.erb"),
        type_letter:      "M"
      },
      "MediaList" => {
        required_params:  %w[doi_batch_id title doi url timestamp publication_year],
        schema_path:      Rails.root.join('data','xsds', 'crossref', '5.4.0', 'crossref5.4.0.xsd'),
        template_path:    Rails.root.join("data", "xmls", "list_doi.xml.erb"),
        type_letter:      "L"
      }
    }.freeze

    def self.type_config(model)
      TYPE_CONFIG.fetch(model) do
        raise "Unknown model type: #{model.inspect}"
      end
    end

    def self.required_params(model)
      type_config(model)[:required_params]
    end

    def self.schema_path(model)
      type_config(model)[:schema_path]
    end

    def self.template_path(model)
      type_config(model)[:template_path]
    end

    def self.type_letter(model)
      type_config(model)[:type_letter]
    end
  end
end
