$(document).ready(function() {
  if ($('div.itemtable.previous_requests').length) { // check if the page is dashboard my previous requests
    $('body').on('shown.bs.modal', '#pageModal', function (e) {
      // If the button to request an individual item is clicked, add that item's id to an input in the form. Otherwise, collect all the checkboxes that have been selected and create an input for each of those.
      if ($(e.relatedTarget).data('item-id')){
        let item_id = $(e.relatedTarget).data('item-id');
        createHiddenInputs(item_id);
      } else {
        let item_ids = [];
        $.each($('.batch_document_selector:checked'), function(){
          item_ids.push($(this).val());
        });
        item_ids.forEach(createHiddenInputs);
      }
    });

    $('body').on('hide.bs.modal', '#pageModal', function() {
      // clear hidden inputs on modal close
      $('div.modal-body form').find('input[name="batch_document_ids[]"]').remove();
    });

    // Adds a new input for each item selected
    function createHiddenInputs(id) {
      $('<input>').attr({
        type: 'hidden',
        name: 'batch_document_ids[]',
        value: id
    }).appendTo('div.modal-body form');
    }
  }
});
