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

  // overriding  processResults to output additional attributes for Institution
  processResults(data, page) {
    let results;
    // TODO: need a better way to pass the work type or attribute list to here
    if (this.url.indexOf('institutions') != -1) {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0], institution_code: obj.institution_code, description: obj.description, address: obj.address, city: obj.city, state_province: obj.state_province, country: obj.country };
                            })
    } else if (this.url.indexOf('taxonomies') != -1) {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0], taxonomy_domain: obj.taxonomy_domain, taxonomy_kingdom: obj.taxonomy_kingdom };
                            })
    } else {
      results = data.map((obj) => {
                               return { id: obj.id, text: obj.label[0] };
                            })      
    }
    return { results: results };
  }
}
