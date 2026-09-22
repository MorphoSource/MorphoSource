// Shared batch-decide behavior for the ownership transfer ItemTable pages (My Transfers Received/Sent, Admin All Transfers).
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
    e.stopPropagation(); // keeps rails-ujs's document-level data-confirm listener from also firing
    var $button = $(this);

    var confirmMessage = $button.data('confirm');
    if (confirmMessage && !window.confirm(confirmMessage)) return;

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
