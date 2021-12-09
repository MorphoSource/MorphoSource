$( document ).ready(function() {
  if ( $('form.team_organization_permissions_edit').length ) {
    $('div#organization-permissions input:checkbox').change(function() {
      if ($(this).is(':checked')) {
        // Clear and disable all other inputs in this section (remove extra multi-selects)
        $(this)
          .parents('div.value-blank-container')
          .find('input:text, select')
          .val('')
          .prop('disabled', true)
          .trigger('change')
          .slice(1).parent().remove() ;
      } else {
        // Reenable all other inputs in this section
        $(this)
          .parents('div.value-blank-container')
          .find('input:text, select')
          .prop('disabled', false)
          .trigger('change');
      }
    });
  }
});