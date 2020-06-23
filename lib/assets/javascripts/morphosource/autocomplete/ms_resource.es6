import Resource from 'hyrax/autocomplete/resource'

export default class MorphosourceResource extends Resource {
  /**
   * Autocomplete for finding possible related works.
   * @param {jQuery} element - The input field to add autocompete to
   * @param {string} url - The url for the autocompete search endpoint
   * @param {Object} options - optional arguments
   * @param {string} options.excluding - The id to exclude from the search
   */
  constructor(element, url, options = {}) {
    super(element, url, options = {});
  }

  // overriding  processResults to output additional attributes for Organization
  processResults(data, page) {
    let results;
    // TODO: need a better way to pass the work type or attribute list to here
    if (this.url.indexOf('organizations') != -1) {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0], organization_type: obj.organization_type, institution_code: obj.institution_code, institution_name: obj.institution_name, collection_code: obj.collection_code, description: obj.description, address: obj.address, city: obj.city, state_province: obj.state_province, country: obj.country, contact_person: obj.contact_person };
                            })
    } else if (this.url.indexOf('devices') != -1) {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0], creator: obj.creator, modality: obj.modality, description: obj.description, organization_institution: obj.organization_institution };
                            })
    } else if (this.url.indexOf('taxonomies') != -1) {
      results = data.map((obj) => {
                              return { 
                                id: obj.id, 
                                text: obj.label[0], 
                                taxonomy_domain: obj.taxonomy_domain,
                                taxonomy_kingdom: obj.taxonomy_kingdom,
                                taxonomy_phylum: obj.taxonomy_phylum,
                                taxonomy_superclass: obj.taxonomy_superclass,
                                taxonomy_class: obj.taxonomy_class,
                                taxonomy_subclass: obj.taxonomy_subclass,
                                taxonomy_superorder: obj.taxonomy_superorder,
                                taxonomy_order: obj.taxonomy_order,
                                taxonomy_suborder: obj.taxonomy_suborder,
                                taxonomy_superfamily: obj.taxonomy_superfamily,
                                taxonomy_family: obj.taxonomy_family,
                                taxonomy_subfamily: obj.taxonomy_subfamily,
                                taxonomy_tribe: obj.taxonomy_tribe,
                                taxonomy_genus: obj.taxonomy_genus,
                                taxonomy_subgenus: obj.taxonomy_subgenus,
                                taxonomy_species: obj.taxonomy_species,
                                taxonomy_subspecies: obj.taxonomy_subspecies,
                                depositor: obj.depositor,
                                depositor_link: obj.depositor_link
                              };
                            })
    } else if (this.url.indexOf('biological_specimens') != -1) {
      results = data.map((obj) => {
                              return { 
                                id: obj.id, 
                                text: obj.label[0], 
                                bibliographic_citation: obj.bibliographic_citation,
                                catalog_number: obj.catalog_number,
                                collection_code: obj.collection_code,
                                canonical_taxonomy: obj.canonical_taxonomy,
                                institution_code: obj.institution_code,
                                latitude: obj.latitude,
                                longitude: obj.longitude,
                                numeric_time: obj.numeric_time,
                                original_location: obj.original_location,
                                periodic_time: obj.periodic_time,
                                vouchered: obj.vouchered,
                                idigbio_recordset_id: obj.idigbio_recordset_id,
                                idigbio_uuid: obj.idigbio_uuid,
                                is_type_specimen: obj.is_type_specimen,
                                occurrence_id: obj.occurrence_id,
                                source_of_record: obj.source_of_record,
                                sex: obj.sex
                              };
                            })
    } else if (this.url.indexOf('cultural_heritage_objects') != -1) {
      results = data.map((obj) => {
                              return { 
                                id: obj.id, 
                                text: obj.label[0], 
                                bibliographic_citation: obj.bibliographic_citation,
                                catalog_number: obj.catalog_number,
                                collection_code: obj.collection_code,
                                institution_code: obj.institution_code,
                                latitude: obj.latitude,
                                longitude: obj.longitude,
                                numeric_time: obj.numeric_time,
                                original_location: obj.original_location,
                                periodic_time: obj.periodic_time,
                                vouchered: obj.vouchered,
                                cho_type: obj.cho_type,
                                material: obj.material,
                                short_title: obj.short_title
                              };
                            })
    } else {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0] };
                            })      
    }
    return { results: results };
  }

}
