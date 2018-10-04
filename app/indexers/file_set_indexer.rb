class FileSetIndexer < Hyrax::FileSetIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['bits_per_sample_tesim']   = object.bits_per_sample
    end
  end

end
