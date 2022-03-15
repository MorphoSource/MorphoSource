//= require morphosource/data_tables/media_table

$(document).ready(function() {

    if ($('body[class*="media-works"]').length) { // check if the page is dashboard media works

      var mediaTable = createMediaTable('#datatable-media-list');

      // Toggle the visibility of table column
      $('.choose-columns-media .toggle-vis').on( 'click', function (e) {
        //e.preventDefault();
        var column = mediaTable.column( $(this).attr('data-column') );
        column.visible( ! column.visible() );
      });

      // keep dropdown menu open
      $(document).on('click', '.choose-columns .dropdown-menu', function (e) {
        e.stopPropagation();
      });

      $(document).on('click', '#add-selected-to-cart', function (e) {
        // todo: any checked checkboxes? disable button
        $('#add-selected-to-cart-hidden').trigger('click');
      });

      $(document).on('click', '#select-all-for-download', function (e) {
        var checkedStatus = this.checked;
        $('.batch_add_selector').each(function() {
          $(this).prop('checked', checkedStatus);
        });
      });

      // handle checkbox for both add to cart and add media to collections
      $('input.batch_add_selector').on('change', function(e){
        id = $(this).attr('id').split('batch_work_')[1];
        $('input#'+'batch_document_'+id).prop('checked', $(this).prop('checked'));
        if ($('input.batch_add_selector:checked').length) {
          $('.batch-action-buttons .btn').removeAttr('disabled').removeClass('disabled');
        } else {
          $('.batch-action-buttons .btn').attr('disabled', 'disabled').addClass('disabled');
        }
      });

      $(document).on('click', '#select-all-for-download', function (e) {
        var checkedStatus = this.checked;
        // select/de-select both set of checkboxes
        $('.batch_add_selector, .batch_document_selector').each(function() {
          $(this).prop('checked', checkedStatus);
        });
        if ($('input.batch_add_selector:checked').length) {
          $('.batch-action-buttons .btn').removeAttr('disabled').removeClass('disabled');
        } else {
          $('.batch-action-buttons .btn').attr('disabled', 'disabled').addClass('disabled');
        }
      });


    } // / end if dashboard media works

});
