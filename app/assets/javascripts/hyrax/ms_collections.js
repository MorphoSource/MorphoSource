// overriding the method from collections.js
Blacklight.onLoad(function () {

  // Remove this sub-collection list button clicked
  $('#sub-collections-wrapper')
    .find('.remove-subcollection-button')
    .on('click', function (e) {

    var dataId = $(this).data('id');
    if (typeof dataId !== typeof undefined) {
      // if the button itself contains data attributes, pass them to the modal
      var $dataEl = $(this),
        modalId = '#collection-remove-subcollection-modal';
    } else {
      var $dataEl = $(this).closest('li'),
        modalId = '#collection-remove-subcollection-modal';
    }
    addDataAttributesToModal(modalId, ['id', 'parent-id', 'post-url'], $dataEl);
    $(modalId).modal('show');
  });

});
