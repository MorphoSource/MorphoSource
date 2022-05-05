import Default from 'hyrax/autocomplete/default'
import MorphosourceResource from './autocomplete/ms_resource'
import Autocomplete from 'hyrax/autocomplete'
import LinkedData from 'hyrax/autocomplete/linked_data'

export default class MorphosourceAutocomplete extends Autocomplete {
  /**
   * Setup for the autocomplete field.
   * @param {jQuery} element - The input field to add autocompete to
   * @param {string} fieldName - The name of the field (e.g. 'based_near')
   * @param {string} url - The url for the autocompete search endpoint
   */
  setup (element, fieldName, url) {
    switch (fieldName) {
      case 'work':
        new MorphosourceResource(
          element,
          url,
          { excluding: element.data('exclude-work') }
        )
        break
      case 'collection':
        new MorphosourceResource(
          element,
          url)
        break
      case 'aat_attribute':
        new LinkedData(element, url)
        break
      case 'aat_material':
        new LinkedData(element, url)
        break
      case 'aat_type':
        new LinkedData(element, url)
        break
      case 'based_near':
        new LinkedData(element, url)
        break
      case 'periodic_time':
        new LinkedData(element, url)
        break
      case 'tgn':
        new LinkedData(element, url)
        break
      default:
        new Default(element, url)
        break
    }
  }
}
