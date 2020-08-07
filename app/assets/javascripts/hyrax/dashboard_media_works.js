$(document).ready(function() {

    if ($('body[class*="media-works"]').length) { // check if the page is dashboard media works

      var mediaTable = $('#datatable-media-list').DataTable({
        responsive: {
          details: {
            type: 'none' // hide the details and button in responsive
          }
        },
        //order: [[ 2, "asc" ]],  // if sorting is needed, we might need to sort the same way in gallery view
        columnDefs: [
          { orderable: false, targets: 0 }, // disable sorting
          { orderable: false, targets: 1 },
          { orderable: false, targets: -1 },
//          { visible: false, targets: 9 }, // hide column by default
          //{ width: "20%", targets: -1 },
          { responsivePriority: 1, targets: 0 },
          { responsivePriority: 2, targets: 1 },
          { responsivePriority: 3, targets: 2 },
          { responsivePriority: 4, targets: -1 } // rightmost column
        ],
        pageLength: 10,
        bPaginate: false,
        bInfo: false,
        bDestroy: true,
        bLengthChange: false, // hide the show number of entries dropdown
        bFilter: false // hide search box
      });

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

      // populate PO BSO counts when the tab has been loaded
      document.addEventListener("bso-loaded", function(event) {
        //console.log("bso have loaded!", event.container);
        $('span.bso-count').html($('input[name="bso-count"]').val() + ' Specimens · ');
        $('.tab-bso-count').html($('input[name="bso-count"]').val());

        var bsoTable = $('#datatable-bso-list').DataTable({
          responsive: {
            details: {
              type: 'none'
            }
          },
          //order: [[ 1, "asc" ]],
          columnDefs: [
            { orderable: false, targets: 0 }, // disable sorting
            { responsivePriority: 1, targets: 0 },
            { responsivePriority: 3, targets: 1 },
            { responsivePriority: 4, targets: 2 }
          ],
          pageLength: 10,
          bPaginate: false,
          bInfo: false,
          bDestroy: true,
          bLengthChange: false, // hide the show number of entries dropdown
          bFilter: false // hide search box
        });

        $('.choose-columns-bso .toggle-vis').on( 'click', function (e) {
          var column = bsoTable.column( $(this).attr('data-column') );
          column.visible( ! column.visible() );
        });

      });

      // populate PO CHO counts when the tab has been loaded
      document.addEventListener("cho-loaded", function(event) {
        //console.log("bso have loaded!", event.container);
        $('span.bso-count').html($('input[name="cho-count"]').val() + ' Objects · ');
        $('.tab-bso-count').html($('input[name="cho-count"]').val());

        var choTable = $('#datatable-cho-list').DataTable({
          responsive: {
            details: {
              type: 'none'
            }
          },
          //order: [[ 1, "asc" ]],
          columnDefs: [
            { orderable: false, targets: 0 }, // disable sorting
            { responsivePriority: 1, targets: 0 },
            { responsivePriority: 3, targets: 1 },
            { responsivePriority: 4, targets: 2 }
          ],
          pageLength: 10,
          bPaginate: false,
          bInfo: false,
          bDestroy: true,
          bLengthChange: false, // hide the show number of entries dropdown
          bFilter: false // hide search box
        });

        $('.choose-columns-cho .toggle-vis').on( 'click', function (e) {
          var column = choTable.column( $(this).attr('data-column') );
          column.visible( ! column.visible() );
        });
      
      });

    } // / end if dashboard media works

});
