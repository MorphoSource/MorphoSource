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
        disablePageAndSave(".dropdown-toggle");
        return true;
      }
    });

    $('form.filters select').change(function() {
      var form_id = $(this).data('form');
      disablePage();
      $('#'+form_id).submit();
    });

    $('[data-behavior="remove-filter"]').on('click', function (e) {
      removing_param = $(this).data('param');
      if (removing_param == 'all') {
        $('[class="filter-param"]').remove();
      } else {
        $('input[name=' + removing_param + ']').remove();
        $('p[id=' + removing_param + ']').remove();        
      }
      var form_id = $(this).data('form');
      disablePage();
      $('#'+form_id).submit();
    });

    form = $('form[id*="edit_collection"]')[0];
    form.addEventListener("submit", function(submitEvent) {
      //submitEvent.preventDefault();
      disablePageAndSave(".dropdown-toggle");
    })

    /*
    $('.tab-action-buttons .btn').click(function() {
      disablePageAndSave(".tab-action-buttons .btn");
    });
    */

    $('.btn-delete-collection').click(function() {
      disablePageAndSave(".dropdown-toggle");
    });

  } // end if collection form page

})
