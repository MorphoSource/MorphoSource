// Shared batch-decide behavior for the ownership transfer ItemTable pages (My Transfers
// Received/Sent, Admin All Transfers). Each page renders its rows and batch-toolbar buttons
// inside one shared #batch-transfer-decide form (see morphosource/transfers/_index_body). A
// batch-decide button doesn't know its own route ahead of time -- each button carries its target
// route on data-url (plus optional data-reset/data-sticky), and this file points the shared form
// at whichever button was clicked before submitting it.
Blacklight.onLoad(function () {
  var $form = $('#batch-transfer-decide');
  if (!$form.length) return;

  $('.select-all-transfers').on('click', function (e) {
    e.preventDefault();
    $('.batch_document_selector').prop('checked', true);
    toggleButtons(true);
  });

  $('.select-no-transfers').on('click', function (e) {
    e.preventDefault();
    $('.batch_document_selector').prop('checked', false);
    toggleButtons();
  });

  $('.batch-decide').on('click', function (e) {
    e.preventDefault();
    var $button = $(this);

    $form.attr('action', $button.data('url'));
    $form.find('input.batch-decide-param').remove();
    if ($button.data('reset')) {
      $('<input />').attr('type', 'hidden').addClass('batch-decide-param').attr('name', 'reset').attr('value', 'true').appendTo($form);
    }
    if ($button.data('sticky')) {
      $('<input />').attr('type', 'hidden').addClass('batch-decide-param').attr('name', 'sticky').attr('value', 'true').appendTo($form);
    }

    $form.submit();
  });
});
