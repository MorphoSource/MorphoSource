$( document ).ready(function() {
	if ($('form').length) { // if any form page
    $('.btn-remove-attachment').click(function() {
      console.log('hi');
      var parent = $(this).parents('.attachment-container');
      parent.find('.attachment-link').addClass('hide');
      parent.find('.attachment-input').removeClass('hide');
      parent.find('input.attachment_delete').val('delete');
    });

    $('input.file-field-input').change(function() {
      if ($(this).val()) {
        $(this).parents('.attachment_container').
          find('input.attachment_delete').val('');
      }
    });
  }

  // Additional behavior for agreement_uri + attachment fields
  if ( 
    $('form[id*="edit_media"]').length ||
    $('form[id*="new_media"]').length ||
    $('form[id*="edit_organization"]').length
  ) {
    $('.btn-remove-attachment').click(function() {
      $('input#media_agreement_uri').removeAttr('disabled');
    });

    $('input.file-field-input.agreement-attachment').change(function() {
      if ($(this).val()) {
        $('input#media_agreement_uri').val('');
        $('input#media_agreement_uri').attr('disabled', 'disabled');
      } else {
        $('input#media_agreement_uri').removeAttr('disabled');
      }
    });
  }
});