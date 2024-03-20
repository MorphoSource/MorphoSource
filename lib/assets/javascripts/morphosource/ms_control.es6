
//import Registry from 'hyrax/relationships/registry'
import Registry from './ms_registry'
import Resource from 'morphosource/relationships/resource'
import OrganizationResource from './ms_organization_resource'
import TaxonomyResource from './ms_taxonomy_resource'
import DeviceResource from './ms_device_resource'
import BiologicalSpecimenResource from './ms_biological_specimen_resource'
import CulturalHeritageObjectResource from './ms_cultural_heritage_object_resource'

/**
 * This depends on the passed in element containing `data-autocomplete="work'"`
 * that is also a select2 element.
*/
export default class RelationshipsControl {

  /**
   * Initializes the class in the context of an individual table element
   * @param {HTMLElement} element the table element that this class represents.
   * @param {Array} members the members to display in the table
   * @param {String} paramKey the key for the type of object we're submitting (e.g. 'generic_work')
   * @param {String} property the property to submit
   * @param {String} templateId the template identifier for new rows
   * @param {String}  indexStart : (Customized) when creating the input hidden field, start the index using this number.  This
   *                      will prevent Hyrax to overwrite a property (e.g. work_parents_attributes) which is used
   *                      in more than one form element
   */
  constructor(element, members, paramKey, property, templateId, indexStart = 0) {
    this.element = $(element)
    this.members = this.element.data('members')
    this.registry = new Registry(this.element.find('tbody'), paramKey, property, templateId, indexStart)
    this.input = this.element.find(`[data-autocomplete]`)
    this.warning = this.element.find(".message.has-warning")
    this.addButton = this.element.find("[data-behavior='add-relationship']")
    this.autoAdd = this.input.data('autoadd') || false
    this.errors = null
    this.repeatable = this.element.data('repeatable') || 'yes'
    this.workType = this.element.data('work-type')
  }

  init() {
    this.bindAddButton();
    this.bindInput();
    this.displayMembers();
  }

  validate() {
    this.errors = null
    let data = this.searchData()

    if (this.input.is("#media_member_of_collection_ids")) {
      if (data.type == "sequential_section_list") {
        let submission_modality = $("select[name='submission[submission_modality]']").val();
        let edit_media_modality = $('#imaging_event_ie_modality').find(":selected").val();
        let modality = (submission_modality || edit_media_modality)
        if (modality != "SequentialSectionScan") {
          this.errors = ["Sequential Section Scan Lists can only contain media with modality Sequential Section Scan"]
          alert(this.errors);
        }
        let submission_object_id = $('#media_member_of_collection_ids').attr('data-selected-object')
        let edit_media_object_id = $('#physical-object-id-value').attr('value')
        let object_id = (submission_object_id || edit_media_object_id);
        if (data.object_id && object_id != data.object_id) {
          this.errors = ["All media in a Sequential Section Scan List must be from object id: " + data.object_id]
          alert(this.errors);
        }
      }
    }

    if (this.input.val() === "") {
      this.errors = ['ID cannot be empty.']
    }
  }

  displayMembers() {
    if (this.workType == 'organization') {
      this.members.forEach((elem) =>
        this.registry.addResource(new OrganizationResource(elem.id, elem.label, elem.organization_type, elem.institution_code, elem.institution_name, elem.collection_code, elem.recordset_id, elem.description, elem.related_url, elem.address, elem.city, elem.state_province, elem.postal_code, elem.country, elem.contact_person))
      )
    } else if (this.workType == 'device') {
      this.members.forEach((elem) =>
        this.registry.addResource(new DeviceResource(elem.id, elem.label, elem.creator, elem.modality, elem.description, elem.organization_institution))
      )
    } else if (this.workType == 'taxonomy') {
      this.members.forEach((elem) =>
        this.registry.addResource(new TaxonomyResource(
          elem.id,
          elem.label,
          elem.taxonomy_domain,
          elem.taxonomy_kingdom,
          elem.taxonomy_phylum,
          elem.taxonomy_superclass,
          elem.taxonomy_class,
          elem.taxonomy_subclass,
          elem.taxonomy_superorder,
          elem.taxonomy_order,
          elem.taxonomy_suborder,
          elem.taxonomy_superfamily,
          elem.taxonomy_family,
          elem.taxonomy_subfamily,
          elem.taxonomy_tribe,
          elem.taxonomy_genus,
          elem.taxonomy_subgenus,
          elem.taxonomy_species,
          elem.taxonomy_subspecies,
          elem.trusted,
          elem.gbif_key,
          elem.depositor,
          this.depositorLink(elem.depositor)
         ))
      )
    } else if (this.workType == 'biological_specimen') {
      this.members.forEach((elem) =>
        this.registry.addResource(new BiologicalSpecimenResource(
          elem.id,
          elem.label,
          elem.bibliographic_citation,
          elem.catalog_number,
          elem.collection_code,
          elem.canonical_taxonomy,
          elem.institution_code,
          elem.latitude,
          elem.longitude,
          elem.numeric_time,
          elem.original_location,
          elem.periodic_time,
          elem.vouchered,
          elem.idigbio_recordset_id,
          elem.idigbio_uuid,
          elem.is_type_specimen,
          elem.occurrence_id,
          elem.source_of_record,
          elem.sex
         ))
      )
    } else if (this.workType == 'cultural_heritage_object') {
      this.members.forEach((elem) =>
        this.registry.addResource(new CulturalHeritageObjectResource(
          elem.id,
          elem.label,
          elem.bibliographic_citation,
          elem.catalog_number,
          elem.collection_code,
          elem.institution_code,
          elem.latitude,
          elem.longitude,
          elem.numeric_time,
          elem.original_location,
          elem.periodic_time,
          elem.vouchered,
          elem.cho_type,
          elem.material,
          elem.short_title
         ))
      )
    } else {
      this.members.forEach((elem) =>
        this.registry.addResource(new Resource(elem.id, elem.label, elem.removable))
      )
    }
  }

  depositorLink(email) {
    // url example: /users/johndoe@gmail-dot-com
    return "/users/" + email.replace(/(.+)@([^.]+)\.(.+)/, '$1@$2-dot-$3')
  }

  isValid() {
    this.validate()
    return this.errors === null
  }

  /**
   * Handle click events by the "Add" button in the table, setting a warning
   * message if the input is empty or calling the server to handle the request
   */
  bindAddButton() {
    this.addButton.on("click", () => this.attemptToAddRow())
  }

  bindInput() {
    if (this.autoAdd) {
      // add row will be called after an option is added (instead of using add button)
      this.input.on("change", () => this.attemptToAddRow())
    }
  }

  attemptToAddRow() {
      // Display an error when the input field is empty, or if the resource ID is already related,
      // otherwise clone the row and set appropriate styles
      if (this.isValid()) {
        this.addRow()
      } else {
        this.setWarningMessage(this.errors.join(', '))
      }
  }

  addRow() {
    this.hideWarningMessage()
    let data = this.searchData()
    console.log('select2 data : ',data)
    if (this.repeatable == 'no') {
      // if the attribute is not repeatable, remove the rest of the items before adding
      this.registry.items.forEach((item, index) => {
        item.removeResource();
      })
    }
    if (this.workType == 'organization') {
      this.registry.addResource(new OrganizationResource(data.id, data.text, data.organization_type, data.institution_code, data.institution_name, data.collection_code, data.recordset_id, data.description, data.related_url, data.address, data.city, data.state_province, data.postal_code, data.country, data.contact_person));
    } else if (this.workType == 'device') {
      this.registry.addResource(new DeviceResource(data.id, data.text, data.creator, data.modality, data.description, data.organization_institution));
    } else if (this.workType == 'taxonomy') {
      console.log(data);
      // if (data.id == data.gbif_key) {
      //   console.log('gbif');
      //   console.log(data);

      //   console.log('Creating new GBIF taxonomy...');
      //   fetch('/submissions/new_taxonomy_submit', {
      //     method: 'post',
      //     body: JSON.stringify( { 'gbif_key': data.gbif_key } )
      //   }).then(function(response) {
      //     return response.json();
      //   }).then(function(new_data) {
      //     console.log(new_data);
      //   });
      // }
      this.registry.addResource(new TaxonomyResource(
        data.id,
        data.text,
        data.taxonomy_domain,
        data.taxonomy_kingdom,
        data.taxonomy_phylum,
        data.taxonomy_superclass,
        data.taxonomy_class,
        data.taxonomy_subclass,
        data.taxonomy_superorder,
        data.taxonomy_order,
        data.taxonomy_suborder,
        data.taxonomy_superfamily,
        data.taxonomy_family,
        data.taxonomy_subfamily,
        data.taxonomy_tribe,
        data.taxonomy_genus,
        data.taxonomy_subgenus,
        data.taxonomy_species,
        data.taxonomy_subspecies,
        data.gbif_key,
        data.depositor,
        data.depositor_link
        ))

    } else if (this.workType == 'biological_specimen') {
      this.registry.addResource(new BiologicalSpecimenResource(
        data.id,
        data.text,
        data.bibliographic_citation,
        data.catalog_number,
        data.collection_code,
        data.canonical_taxonomy,
        data.institution_code,
        data.latitude,
        data.longitude,
        data.numeric_time,
        data.original_location,
        data.periodic_time,
        data.vouchered,
        data.idigbio_recordset_id,
        data.idigbio_uuid,
        data.is_type_specimen,
        data.occurrence_id,
        data.source_of_record,
        data.sex
        ))
    } else if (this.workType == 'cultural_heritage_object') {
      this.registry.addResource(new CulturalHeritageObjectResource(
        data.id,
        data.text,
        data.bibliographic_citation,
        data.catalog_number,
        data.collection_code,
        data.institution_code,
        data.latitude,
        data.longitude,
        data.numeric_time,
        data.original_location,
        data.periodic_time,
        data.vouchered,
        data.cho_type,
        data.material,
        data.short_title
        ))
    } else {
      this.registry.addResource(new Resource(data.id, data.text))
    }
    // prepare form data (e.g. add hidden fields for work_parents_attributes) for ajax post
    // (e.g. adding parents for imaging event)
    this.registry.serializeToForm();
    // finally, empty the "add" row input value
    this.clearSearch();
  }

  searchData() {
    // if new work has been created, use data from new work instead
    var new_data = this.element.data("new-work-created")
    //console.log('new_data : ', new_data)
    if ($.isEmptyObject(new_data)) {
      //console.log('searchData data : ', this.input.select2('data'))
      return this.input.select2('data')
    } else {
      return new_data
    }
  }

  clearSearch() {
    this.input.select2("val", '');
    this.element.data("new-work-created", '');
  }

  /**
   * Set the warning message related to the appropriate row in the table
   * @param {String} message the warning message text to set
   */
  setWarningMessage(message) {
    this.warning.text(message).removeClass("hidden");
  }

  /**
   * Hide the warning message on the appropriate row
   */
  hideWarningMessage(){
    this.warning.addClass("hidden");
  }
}
