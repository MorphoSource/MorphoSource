import SaveWorkControl from 'hyrax/save_work/save_work_control'

import { RequiredFields } from 'hyrax/save_work/required_fields'
import { ChecklistItem } from 'hyrax/save_work/checklist_item'
import { UploadedFiles } from 'hyrax/save_work/uploaded_files'
import { DepositAgreement } from 'hyrax/save_work/deposit_agreement'
import VisibilityComponent from 'hyrax/save_work/visibility_component'

export default class MorphosourceSaveWorkControl extends SaveWorkControl {

  // Overrides to add listener for change in Media work format requirement.
  activate() {
    if (!this.form) {
      return
    }
    this.requiredFields = new RequiredFields(this.form, () => this.formStateChanged())
    this.uploads = new UploadedFiles(this.form, () => this.formStateChanged())
    this.saveButton = this.element.find(':submit')
    this.depositAgreement = new DepositAgreement(this.form, () => this.formStateChanged())
    this.requiredMetadata = new ChecklistItem(this.element.find('#required-metadata'))
    this.requiredFiles = new ChecklistItem(this.element.find('#required-files'))
    this.requiredFormat = new ChecklistItem(this.element.find('#required-format'))
    this.requiredAgreement = new ChecklistItem(this.element.find('#required-agreement'))
    new VisibilityComponent(this.element.find('.visibility'), this.adminSetWidget)
    this.preventSubmit()
    this.watchMultivaluedFields()
    this.watchFormatRequirement()
    this.formChanged()
    this.addFileUploadEventListeners()
    this.checkValidFormats()
  }

  // Overrides to include validateFormats requirement.
  isValid() {
    // avoid short circuit evaluation. The checkboxes should be independent.
    let metadataValid = this.validateMetadata()
    let filesValid = this.validateFiles()
    let agreementValid = this.validateAgreement(filesValid)
    let formatsValid = this.validateFormats()
    return metadataValid && filesValid && agreementValid && formatsValid
  }

  // Checks whether formats requirement has been fulfilled.
  // Check mark happens in upload_formats #fulfill_requirement.
  validateFormats() {
    // Return true if not on Media Work form.
    if ($('form[id*="media"]').length == 0) {
      return true
    }
    // Return true if file formats requirement has been fulfilled.
    else if ($('#required-format').hasClass('complete')){
      return true
    }
    else {
      return false
    }
  }

  // When editing a document, check file formats requirement complete if required files is valid and there are no new files in the upload tab.
  checkValidFormats() {
    if (this.validateFiles() && $('input[name="uploaded_files[]"]').length == 0) {
      this.requiredFormat.check();
    }
  }

  // Watch for changes to the file formats requirement, if there's a change, let Hyrax know to check if the form is valid.
  watchFormatRequirement() {
    var formatsRequirement = document.getElementById('required-format');
    var that = this
    var callback = function(mutationsList, observer) {
      for(var mutation of mutationsList) {
        if (mutation.type == 'attributes') {
          // if attributes change (complete/incomplete), let Hyrax know.
          that.formChanged();
        }
      }
    };

    // Return if not on Media Work form.
    if ($('form[id*="media"]').length == 0) {
      return;
    }

    new MutationObserver(callback).observe(formatsRequirement, {attributes: true});
  };
};
