//= require handlebars-v4.0.5

import { FieldManager } from 'hydra-editor/field_manager'
import Handlebars from 'handlebars'
import Autocomplete from 'hyrax/autocomplete'
import MorphosourceAutocomplete from 'morphosource/ms_autocomplete'

export default class GettyControlledVocabulary extends FieldManager {

  constructor(element, paramKey) {
      let options = {
        /* callback to run after add is called */
        add:    null,
        /* callback to run after remove is called */
        remove: null,

        controlsHtml:      '<span class=\"input-group-btn field-controls\">',
        fieldWrapperClass: '.field-wrapper',
        warningClass:      '.has-warning',
        listClass:         '.listing',
        inputTypeClass:    '.controlled_vocabulary',

        addHtml:           '<button type=\"button\" class=\"btn btn-link getty add\" style=\"visibility: hidden;\"><i class="fa fa-plus-circle" aria-hidden="true" style="position: relative; bottom: 6px;"></i></i></button>',
        addText:           'Add another',

        removeHtml:        '<button type=\"button\" class=\"btn btn-link remove\" style=\"visibility: hidden;\"><i class=\"fa fa-times-circle\"></i><span class=\"sr-only\"> previous <span class="controls-field-name-text">field</span></span></button>',
        removeText:         'Remove',

        labelControls:      true,
      }
      super(element, options)
      this.paramKey = paramKey
      this.fieldName = this.element.data('fieldName')
      this.searchUrl = this.element.data('autocompleteUrl')
  }

  _attachEvents() {
    this.element.on('click', this.removeSelector, (e) => this.removeFromList(e))
    this.element.on('click', this.addSelector, (e) => this.addSearchToList(this.element))

    // when a value is selected in the search box, create a new search box at the top of the list of values.
    let $search = $(this.element).children('input').first()
     $(this.element).on('change', $search, (e) => {
       this.addSearchToList(this.element)
     })
  }

  _createRemoveControl() {
    $(this.fieldWrapperClass + ' .field-controls', this.element).append(this.remover)
    $(this.fieldWrapperClass + ' .field-controls', this.element).each ((_idx, element) => {
      if ($(element).siblings('.select2-container-disabled').length) {
        let button = $(element).find('button').first()
        $(button).css("visibility", "visible")
      }
    })
  }

  createRemoveHtml(options) {
    var $removeHtml = $(options.removeHtml);
    $removeHtml.find('.controls-remove-text').html(options.removeText);
    $removeHtml.find('.controls-field-name-text').html(options.label);
    return $removeHtml;
    }

  // Overrides FieldManager in order to avoid doing a clone of the existing field
  createNewField($activeField) {
    let $newField = this._newFieldTemplate()
    this._addBehaviorsToInput($newField)
    this.element.trigger("managed_field:add", $newField);
    return $newField
  }

  /* This gives the index for the editor */
  _maxIndex() {
    return $(this.fieldWrapperClass, this.element).length
  }

  // when a value is selected, create a new search box at the top
  addSearchToList( element ) {
    let $listing = $(element).closest(this.inputTypeClass).find(this.listClass)
    let $activeField = $listing.children('li').first()
    let $newField = $(this._newField($activeField))

    $listing.prepend($newField);

    $(element).find('button').each((_idx, button) => {
      if (_idx == 0) {
        $(button).css("visibility", "hidden")
      } else if ($(button).hasClass("add")) {
        $(button).css("visibility", "hidden")
      } else {
        $(button).css("visibility", "visible");
      }
    });
   this._manageFocus()
  }

  // Overridden because we always want to permit adding another row
  inputIsEmpty(activeField) {
      return false
  }

  _newFieldTemplate() {
    let index = this._maxIndex()
    let rowTemplate = this._template()
    let controls = this.controls.clone()//.append(this.remover)

    let row =  $(rowTemplate({ "paramKey": this.paramKey,
                               "name": this.fieldName,
                               "index": index,
                               "class": "controlled_vocabulary" }))
                .append(controls)
    return row
  }

  get _source() {
    return "<li class=\"field-wrapper input-group input-append\">" +
      "<input class=\"string {{class}} optional form-control {{paramKey}}_{{name}} form-control multi-text-field\" name=\"{{paramKey}}[{{name}}_attributes][{{index}}][hidden_label]\" value=\"\" id=\"{{paramKey}}_{{name}}_attributes_{{index}}_hidden_label\" data-attribute=\"{{name}}\" type=\"text\">" +
      "<input name=\"{{paramKey}}[{{name}}_attributes][{{index}}][id]\" value=\"\" id=\"{{paramKey}}_{{name}}_attributes_{{index}}_id\" type=\"hidden\" data-id=\"remote\">" +
      "<input name=\"{{paramKey}}[{{name}}_attributes][{{index}}][_destroy]\" id=\"{{paramKey}}_{{name}}_attributes_{{index}}__destroy\" value=\"\" data-destroy=\"true\" type=\"hidden\"></li>"
  }

  _template() {
    return Handlebars.compile(this._source)
  }

  /**
  * @param {jQuery} $newField - The <li> tag
  */
  _addBehaviorsToInput($newField) {
      let $newInput = $('input.multi-text-field', $newField)
      $newInput.focus()
      this.addAutocompleteToEditor($newInput)
      this.element.trigger("managed_field:add", $newInput)
  }

  /**
  * Make new element have autocomplete behavior
  * @param {jQuery} input - The <input type="text"> tag
  */
  addAutocompleteToEditor(input) {
    var autocomplete = new MorphosourceAutocomplete()
    autocomplete.setup(input, this.fieldName, this.searchUrl)
  }

  // Overrides FieldManager
  // Instead of removing the line, we override this method to add a
  // '_destroy' hidden parameter
  removeFromList( event ) {
    event.preventDefault()
    let field = $(event.target).parents(this.fieldWrapperClass)
    // if the value is not an already existing attribute (the user has selected a new value and then removed it)
    // remove the getty uri, do not set '_destroy'
    // otherwise, set _destroy on the already existing attribute
    if (!field.find(('input[id^="s2id"]')).length){
      field.find('[data-id]').val('')
    } else {
      field.find('[data-destroy]').val('true')
    }
    field.hide()
    this.element.trigger("managed_field:remove", field)
  }
}
