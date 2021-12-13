$( document ).ready(function() {
  var blankValueEffect = function(element) {
    if (element.is(':checked')) {
        // Clear and disable all other inputs in this section (remove extra multi-selects)
        $(element)
          .parents('div.value-blank-container')
          .find('input:text, select')
          .val('')
          .prop('disabled', true)
          .trigger('change')
          .slice(1).parent().remove() ;
      } else {
        // Reenable all other inputs in this section
        $(element)
          .parents('div.value-blank-container')
          .find('input:text, select')
          .prop('disabled', false)
          .trigger('change');
      }
  };

  if ( $('form.team_organization_permissions_edit').length ) {
    $('div#organization-permissions input:checkbox').each(function() {
      blankValueEffect($(this));
    });

    $('div#organization-permissions input:checkbox').change(function() {
      blankValueEffect($(this));
    });
  }
});