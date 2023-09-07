  //= require morphosource/data_tables/collections_table

  $(document).ready(function() {

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


    if ($('body.dashboard.collections-list').length) { // check if the page is dashboard collections

      var collectionsTable = createCollectionsTable('#datatable-collections-list');

      // Toggle the visibility of table column
      $('.choose-columns-collections .toggle-vis').on( 'click', function (e) {
        //e.preventDefault();
        var column = collectionsTable.column( $(this).attr('data-column') );
        column.visible( ! column.visible() );
      });

      // keep dropdown menu open
      $(document).on('click', '.choose-columns .dropdown-menu', function (e) {
        e.stopPropagation();
      });

    } // / end if dashboard collections



  })
