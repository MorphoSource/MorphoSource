require 'nokogiri'
require 'erb'
require 'ostruct'
require 'rest-client'
require 'securerandom'

module Morphosource
  module CrossrefDoiMinter
    extend ActiveSupport::Autoload

    SUBMISSION_PATH = 'servlet/deposit'
    @@xsd_schema = nil

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
    def self.validate_metadata_deposit_xml(input_xml)
      # memoized XSD parsing, since parsing the XSD is somewhat time-consuming
      @@xsd_schema ||= Nokogiri::XML::Schema(File.open(Rails.root.join('data','xsds','crossref4.4.2.xsd')))
      validation_errors = @@xsd_schema.validate(Nokogiri::XML(input_xml))
      if validation_errors.empty?
        return input_xml
      else
        raise "Error(s) validating Crossref metadata deposit XML: #{validation_errors.inspect}"
      end
    end

    def self.identifier_to_doi(identifier)
      "#{ENV['CROSSREF_DOI_SHOULDER']}/M#{identifier.sub(/^0*/,'')}"
    end

    # Required keys in params hash:
    # - title
    # - author_first
    # - author_last
    # - url
    # - resource_type
    def self.generate_metadata_deposit_xml(identifier, params={})
      doi = identifier_to_doi(identifier)
      # set timestamp and publication_year if not passed in
      params.reverse_merge!({'timestamp' => Time.now.to_i, 'publication_year' => Time.now.year})
      # always set doi_batch_id and doi
      params.merge!({'doi_batch_id' => SecureRandom.uuid, 'doi' => doi})
      required_params = %w{ doi_batch_id author_first author_last title doi url resource_type timestamp publication_year }
      required_params.each do |required_param|
        if params[required_param].blank?
          raise "CrossrefDoiMinter.generate_metadata_deposit_xml call missing required parameter: #{required_param}"
        else
          params[required_param] = params[required_param].to_s.encode(xml: :text)
        end
      end
      template_path = Rails.root.join('data','xmls','doi.xml.erb')
      rendered_xml = CrossrefMetadataTemplate.new(params).render(File.new(template_path).read)
      Rails.logger.info("CrossrefDoiMinter.generate_metadata_deposit_xml rendered deposit XML: #{rendered_xml}")
      return validate_metadata_deposit_xml(rendered_xml)
    end

    def self.mint_doi(identifier, metadata_params={})
      %w{username password shoulder url}.each do |doi_param|
        environment_param = "CROSSREF_DOI_#{doi_param.upcase}"
        if ENV[environment_param].blank?
          Rails.logger.error "Required environment variable for Crossref DOI minting is missing: #{environment_param}"
          return nil
        end
      end
      submission_url = "#{ENV['CROSSREF_DOI_URL']}/#{SUBMISSION_PATH}"
      login_id = ENV['CROSSREF_DOI_USERNAME']
      login_passwd = ENV['CROSSREF_DOI_PASSWORD']
			deposit_xml = generate_metadata_deposit_xml(identifier, metadata_params)
      # See: https://www.crossref.org/education/member-setup/direct-deposit-xml/https-post/
      submission_response = RestClient.post(submission_url, multipart: true, fname: string_to_file(deposit_xml), login_id: login_id, login_passwd: login_passwd, headers: {content_type: "multipart/form-data"})
      Rails.logger.info("CrossrefDoiMinter.mint_doi submission response: #{submission_response.body}")
      if submission_response.code == 200
        return identifier_to_doi(identifier)
      else
        return nil
      end
    end
  end
end
