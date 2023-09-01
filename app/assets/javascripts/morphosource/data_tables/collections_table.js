


    var createCollectionsTable = function(selector) {
      return $(selector).DataTable({
        responsive: {
          details: {
            display: $.fn.dataTable.Responsive.display.childRowImmediate,
            type: ''
          }
        },
        //order: [[ 2, "asc" ]],  // if sorting is needed, we might need to sort the same way in gallery view
        columnDefs: [
          { orderable: false, targets: 0 }, // disable sorting
          { responsivePriority: 1, targets: 0 },
          { orderable: false, targets: 1 }, // disable sorting
          { responsivePriority: 2, targets: 1 },
          { responsivePriority: 3, targets: 2 },
          { orderable: false, targets: -1 } // disable sorting,
        ],
        pageLength: 10,
        bPaginate: false,
        bInfo: false,
        bDestroy: true,
        bLengthChange: false, // hide the show number of entries dropdown
        bFilter: false, // hide search box
        ordering: false
      });
    }





    // Toggle the visibility of table column
    // $('.choose-columns-collections .toggle-vis').on( 'click', function (e) {
    //   //e.preventDefault();
    //   var column = collectionsTable.column( $(this).attr('data-column') );
    //   column.visible( ! column.visible() );
    // });

    // // keep dropdown menu open
    // $(document).on('click', '.choose-columns .dropdown-menu', function (e) {
    //   e.stopPropagation();
    // });

  // } // / end if dashboard collections

// });