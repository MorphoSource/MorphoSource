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
                               return { id: obj.id, text: obj.label[0], institution_code: obj.institution_code, institution_name: obj.institution_name, collection_code: obj.collection_code, description: obj.description, address: obj.address, city: obj.city, state_province: obj.state_province, country: obj.country };
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
    } else {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0] };
                            })      
    }
    return { results: results };
  }

}
