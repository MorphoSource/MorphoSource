$(document).on('turbolinks:load', function() {

  if ( $('form[id*="edit_collection"]').length || 
       $('form[id*="new_collection"]').length ) { // if collection form page (add/edit)

    setupTooltip();
    removeLastRepeatable();

    /* 
    form.addEventListener("submit", function(mediaSubmitEvent) {

      mediaSubmitEvent.preventDefault();

      if (isFormValid()) {
        disablePageAndSave(".btn-save-media");

      }

    })
    */

  } // end if collection form page

})
