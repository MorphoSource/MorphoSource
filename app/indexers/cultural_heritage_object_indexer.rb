# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
class CulturalHeritageObjectIndexer < Morphosource::PhysicalObjectIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
   super.tap do |solr_doc|
     combined_material_terms = (object.material + Array(solr_doc['aat_material_label_tesim'])).compact.sort_by{|t| t.downcase}
     combined_type_terms = (object.cho_type + Array(solr_doc['aat_type_label_tesim'])).compact.sort_by{|t| t.downcase}

     solr_doc['material_si'] = combined_material_terms&.first&.downcase
     solr_doc['cho_type_si'] = combined_type_terms&.first&.downcase
     solr_doc['vouchered_si'] = object.vouchered&.first&.downcase
   end
  end
end
