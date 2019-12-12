//import RegistryEntry from 'hyrax/relationships/registry_entry'
import RegistryEntry from './ms_registry_entry'
export default class Registry {
  /**
   * Initialize the registry
   * @param {jQuery} element the jquery selector for the permissions container.
   *                         must be a table with a tbody element.
   * @param {String} object_name the name of the object, for constructing form fields (e.g. 'generic_work')
   * @param {String} templateId the the identifier of the template for the added elements
   * @param {String}  indexStart : (Customized) when creating the input hidden field, start the index using this number.  This 
   *                      will prevent Hyrax to overwrite a property (e.g. work_parents_attributes) which is used
   *                      in more than one form element 
   */
  constructor(element, objectName, propertyName, templateId, indexStart) {
    this.objectName = objectName
    this.propertyName = propertyName

    this.templateId = templateId
    this.items = []
    this.element = element
    this.indexStart = indexStart
    element.closest('form').on('submit', (evt) => {
        this.serializeToForm()
    });
  }

  // Return an index for the hidden field when adding a new row.
  // A large random will probably avoid collisions.
  nextIndex() {
      return Math.floor(Math.random() * 1000000000000000)
  }

  export() {
      return this.items.map(item => item.export())
  }

  serializeToForm() {
      // (Customized) See explanation of the indexStart param above    
      this.export().forEach((item, index) => {
          this.addHiddenField(this.indexStart+index, 'id', item.id)
          this.addHiddenField(this.indexStart+index, '_destroy', item['_destroy'])
      })
 }

  addHiddenField(index, key, value) {
      $('<input>').attr({
          type: 'hidden',
          name: `${this.fieldPrefix(index)}[${key}]`,
          value: value
      }).appendTo(this.element)
  }

  // Adds the resource to the first row of the tbody
  addResource(resource) {
      resource.index = this.nextIndex()
      let entry = new RegistryEntry(resource, this, this.templateId)
      this.items.push(entry)
      this.element.prepend(entry.view)
      this.showSaveNote()
  }

  fieldPrefix(counter) {
    return `${this.objectName}[${this.propertyName}][${counter}]`
  }

  showSaveNote() {
    // TODO: we may want to reveal a note that changes aren't active until the resource is saved
  }
}
