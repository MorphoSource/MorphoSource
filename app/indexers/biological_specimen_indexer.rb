# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
class BiologicalSpecimenIndexer < Morphosource::PhysicalObjectIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
     # taxonomy
     taxonomies_titles = object.taxonomies_titles
     gbif_taxonomy_terms = object.gbif_taxonomy_terms
     solr_doc['taxonomy_tesim'] = taxonomies_titles
     solr_doc['taxonomy_ssim'] = taxonomies_titles
     solr_doc['external_taxonomy_tesim'] = gbif_taxonomy_terms
     solr_doc['external_taxonomy_ssim'] = gbif_taxonomy_terms
     solr_doc['record_source_ssim'] = object.record_source
     solr_doc['taxonomy_id_ssim'] = object.taxonomy_id

     # sorting fields
     solr_doc['taxonomy_si'] = taxonomies_titles&.first&.downcase
     solr_doc['record_source_si'] = object.record_source&.downcase
    end
  end
end
