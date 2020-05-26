$(document).on('turbolinks:load', function() {

  if ( $('form[id*="edit_collection"]').length || 
       $('form[id*="new_collection"]').length ) { // if collection form page (add/edit)

    setupTooltip();
    removeLastRepeatable();

    // Handling Actions dropdown menu clicks
    $('.actions-add-subcollection').on('click', function (e) {
      $('.sub-collections-wrapper button.add-subcollection').trigger('click');
    });

    $('.btn-remove-media').on('click', function (e) {
      if (confirm('Remove this media?') == false) {
        e.preventDefault();
        return false;
      } else {
        return true;
      }
    });

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
