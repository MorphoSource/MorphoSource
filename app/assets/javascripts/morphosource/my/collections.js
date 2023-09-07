  //= require morphosource/data_tables/collections_table

  $(document).ready(function() {

    var collectionsTable = createCollectionsTable('#datatable-collections-list');

    // the following are taken from and overridden for lists
    // https://raw.githubusercontent.com/samvera/hyrax/v2.7.0/app/assets/javascripts/hyrax/collections.js
    $('.delete-collection-button').on('click', handleDeleteCollection);

    function handleDeleteCollection(e) {
      e.preventDefault();
      var $self = $(this),
        $tr = $self.parents('tr'),
        totalitems = $self.data('totalitems'),
        // membership set to true indicates admin_set
        membership = false,
        collectionId = $tr.data('id')

      modalId = '#collection-to-delete-modal';
      console.log(modalId)
      addDataAttributesToModal(modalId, ['id', 'post-delete-url'], $tr);
      $(modalId).modal('show');
    }

    function addDataAttributesToModal(modalId, dataAttributes, $dataEl) {
      // Remove and add new data attributes
      dataAttributes.forEach(function(attribute) {
        $(modalId).removeAttr('data-' + attribute).attr('data-' + attribute, $dataEl.data(attribute));
      });
    }

  })
