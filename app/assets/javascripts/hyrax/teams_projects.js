//= require morphosource/data_tables/media_table
//= require morphosource/data_tables/bso_table
//= require morphosource/data_tables/cho_table

$(document).ready(function() {

    if ($('body[class*="teams"]').length) { // check if the page is teams/projects show page

      if ($('body[class*="media-lists"]').length || $('body[class*="sequential_section_lists"]').length) {
        var mediaTable = createMediaTableWithPreview('#datatable-media-list');
      } else {
        var mediaTable = createMediaTable('#datatable-media-list');
      }

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

      $('input.batch_add_selector').on('change', function(e){
        if ($('input.batch_add_selector:checked').length) {
          $('.batch-action-buttons .btn:not(.save-media-order)').removeAttr('disabled').removeClass('disabled');
        } else {
          $('.batch-action-buttons .btn:not(.save-media-order)').attr('disabled', 'disabled').addClass('disabled');
        }
      });

      $(document).on('click', '#select-all-for-download', function (e) {
        var checkedStatus = this.checked;
        $('.batch_add_selector').each(function() {
          $(this).prop('checked', checkedStatus);
        });
        if ($('input.batch_add_selector:checked').length) {
          $('.batch-action-buttons .btn:not(.save-media-order)').removeAttr('disabled').removeClass('disabled');
        } else {
          $('.batch-action-buttons .btn:not(.save-media-order)').attr('disabled', 'disabled').addClass('disabled');
        }
      });

      // populate PO BSO counts when the tab has been loaded
      document.addEventListener("bso-loaded", function(event) {
        //console.log("bso have loaded!", event.container);
        $('span.bso-count').html(' · ' + pluralize('Specimen', $('input[name="bso-count"]').val()));
        $('.tab-bso-count').html($('input[name="bso-count"]').val());

        var bsoTable = createBiologicalSpecimenTable('#datatable-bso-list');

        $('.choose-columns-bso .toggle-vis').on( 'click', function (e) {
          var column = bsoTable.column( $(this).attr('data-column') );
          column.visible( ! column.visible() );
        });
      });

      // populate PO CHO counts when the tab has been loaded
      document.addEventListener("cho-loaded", function(event) {
        $('span.cho-count').html(' · ' + pluralize('Cultural Heritage Object', $('input[name="cho-count"]').val()));
        $('.tab-cho-count').html($('input[name="cho-count"]').val());

        var choTable = createCulturalHeritageObjectTable('#datatable-cho-list');

        $('.choose-columns-cho .toggle-vis').on( 'click', function (e) {
          var column = choTable.column( $(this).attr('data-column') );
          column.visible( ! column.visible() );
        });
      });

    } // / end if teams and projects show page

});
