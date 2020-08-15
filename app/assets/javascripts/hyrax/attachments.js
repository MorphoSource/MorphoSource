$( document ).ready(function() {
	if ($('form').length) { // if form page
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
});