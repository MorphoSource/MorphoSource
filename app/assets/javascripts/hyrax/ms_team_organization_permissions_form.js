$( document ).ready(function() {
  var blankValueEffect = function(element) {
    var specific_element;
    if (element.is(':checked')) {
        // Clear and disable all other inputs in this section (remove extra multi-selects)
        specific_element = $(element)
          .parents('div.value-blank-container')
          .find('input:text, select');

        specific_element
          .val('')
          .prop('placeholder', '')
          .prop('disabled', true)
          .trigger('change');

        // Remove extra multi-selects
        specific_element
          .slice(1).parent().remove();

        // Change placeholder option text value for selects
        specific_element
          .find('option[value=""]')
          .text('');
      } else {
        // Reenable all other inputs in this section
        specific_element = $(element)
          .parents('div.value-blank-container')
          .find('input:text, select');

        specific_element
          .prop('placeholder', $('#placeholder-text').text())
          .prop('disabled', false)
          .trigger('change');

        // Change placeholder option text value for selects
        specific_element
          .find('option[value=""]')
          .text($('#placeholder-text').text());
      }
  };

  if ( $('.allowed-remote-source-wrapper').length ) {
    $('#collection_can_submit_remote_files').on('change', function() {
      if ($(this).val() == 'Yes') {
        $('.allowed-remote-source-wrapper').addClass('show').removeClass('hidden');
      } else {
        $('.allowed-remote-source-wrapper').addClass('hidden').removeClass('show');        
      }
    });
  }

  if ( $('form.team_organization_permissions_edit').length ) {

    $('div#organization-permissions input:checkbox').each(function() {
      blankValueEffect($(this));
    });

    $('div#organization-permissions input:checkbox').change(function() {
      blankValueEffect($(this));
    });
  }
});