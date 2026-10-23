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

  if (
    $('form.team_organization_permissions_edit').length ||
    $('form[id*="edit_organization_collection"]').length
  ) {

    $('div#organization-permissions input:checkbox').each(function() {
      blankValueEffect($(this));
    });

    $('div#organization-permissions input:checkbox').change(function() {
      blankValueEffect($(this));
    });

    const reviewerBlock = document.getElementById('organization-download-reviewers');
    if (reviewerBlock) {
      const pickerRow = document.getElementById('organization-custom-download-reviewers');
      const picker = document.getElementById('organization_collection_custom_download_reviewer_users');
      const pickerError = document.getElementById('organization-custom-download-reviewers-error');
      const customRadio = document.getElementById('organization_collection_managers_are_download_reviewers_false');

      $(picker).userSearchMultiple($(picker).data('reviewers'));
      if (picker.disabled) {
        $(picker).select2('enable', false);
      }
      pickerRow.classList.toggle('d-none', !customRadio.checked);
      // jQuery on purpose: select2 3.x fires change through jQuery only.
      $(picker).on('change', function() {
        pickerError.classList.add('d-none');
      });

      reviewerBlock.querySelectorAll('input[type="radio"]').forEach(function(radio) {
        radio.addEventListener('change', function() {
          // Hide only: clearing the picker here would wipe the stored custom list on save.
          pickerRow.classList.toggle('d-none', !customRadio.checked);
          pickerError.classList.add('d-none');
        });
      });

      const submitButton = document.getElementById('update_submit');
      if (submitButton) {
        submitButton.addEventListener('click', function(event) {
          const pickerEmpty = picker.value.trim() === '';
          if (customRadio.checked && !customRadio.disabled && pickerEmpty) {
            event.preventDefault();
            pickerError.classList.remove('d-none');
            pickerRow.scrollIntoView({ block: 'center' });
          }
        });
      }
    }
  }
});