# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
class CulturalHeritageObjectIndexer < Morphosource::PhysicalObjectIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # including for Getty values
  include Morphosource::IndexesLinkedMetadata

  def generate_solr_document
   super.tap do |solr_doc|
     solr_doc['material_si'] = object.material&.first&.downcase
     solr_doc['cho_type_si'] = object.cho_type&.first&.downcase
     solr_doc['vouchered_si'] = object.vouchered&.first&.downcase
   end
  end
end
