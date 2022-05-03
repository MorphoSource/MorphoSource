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
     solr_doc['material_si'] = object.material&.first&.downcase
     solr_doc['cho_type_si'] = object.cho_type&.first&.downcase
     solr_doc['vouchered_si'] = object.vouchered&.first&.downcase
     solr_doc['object_attributes_ssim'] = object_attributes
     solr_doc['object_attributes_tesim'] = object_attributes
     solr_doc['object_material_ssim'] = object_material
     solr_doc['object_material_tesim'] = object_material
     solr_doc['object_type_ssim'] = object_type
     solr_doc['object_type_tesim'] = object_type
   end
  end

  def object_attributes
    object.aat_attributes + object.cho_attributes
  end

  def object_material
    object.aat_material + object.material
  end

  def object_type
    object.aat_type + object.cho_type
  end
end
