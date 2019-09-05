//TODO: need to override this function later

// This widget manages the adding and removing of repeating fields.
// There are a lot of assumptions about the structure of the classes and elements.
// These assumptions are reflected in the MultiValueInput class.

(function($){
    var DEFAULTS = {
        /* callback to run after add is called */
        add:    null,
        /* callback to run after remove is called */
        remove: null,

        controlsHtml:      '<span class=\"input-group-btn field-controls\">',
        fieldWrapperClass: '.field-wrapper',
        warningClass:      '.has-warning',
        listClass:         '.listing',
        inputTypeClass:    '.multi_value',

        addHtml:           '<button type=\"button\" class=\"btn btn-link add\"><i class=\"fa fa-plus-circle\"></i></button>',
        addText:           'Add another',

        removeHtml:        '<button type=\"button\" class=\"btn btn-link remove\"><i class="fa fa-times-circle"></i><span class="controls-remove-text"></span> <span class=\"sr-only\"> previous <span class="controls-field-name-text">field</span></span></button>',
        removeText:         'Remove',

        labelControls:      true,
    }

    $.fn.manage_fields = function(option) {
        //var hydra_editor = require('hydra-editor/field_manager')
        var hydra_editor = require('morphosource/field_manager')
        return this.each(function() {
            var $this = $(this);
            var data  = $this.data('manage_fields');
            var options = $.extend({}, DEFAULTS, $this.data(), typeof option == 'object' && option);
            if (!data) $this.data('manage_fields', (data = new hydra_editor.FieldManager(this, options)));
        })
    }
})(jQuery);
