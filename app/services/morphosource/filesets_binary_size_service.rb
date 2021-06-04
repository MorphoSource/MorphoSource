module Morphosource
  class FilesetsBinarySizeService
    include SolrHelper

    attr_reader :fileset_ids, :solr
    attr_accessor :fileset_docs

    def self.call(fileset_ids)
      new(fileset_ids).call
    end

    def initialize(fileset_ids)
      @fileset_ids = Array(fileset_ids)
      @solr = solr_service.new
    end

    def call
      return [] if !fileset_ids.present?
      @fileset_docs = query_fileset_docs
      query_filesets_binary_size
    end

    def query_fileset_docs
      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:FileSet",
          assemble_or_query('id', fileset_ids)
        ],
        fl: [
          'id',
          'original_file_id_ssi'
        ]
      }

      solr.get_docs(nil, solr_params)
    end

    def query_filesets_binary_size
      @fileset_docs = @fileset_docs.map do |fs|
        filesize = fileset_binary_size(fs)
        if filesize.present?
          fs.merge( { 'file_size_lts' => filesize.to_i } )
        else
          nil
        end
      end.compact
    end

    def fileset_binary_size(fs)
      return nil if !fs['original_file_id_ssi'].present?
      uri = URI(ActiveFedora::File.id_to_uri(fs['original_file_id_ssi']))
      response = nil

      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri)
      }

      return response['content-length']
    end
  end
end