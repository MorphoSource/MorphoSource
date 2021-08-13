$(document).ready(function() {

    if ($('body.teams.browse').length) { // check if the page is browse teams/projects 

      var collectionsTable = $('#collections-list-table').DataTable({
        responsive: {
          details: {
            display: $.fn.dataTable.Responsive.display.childRowImmediate,
            type: ''
          }
        },
        //order: [[ 2, "asc" ]],  // if sorting is needed, we might need to sort the same way in gallery view
        columnDefs: [
          { responsivePriority: 1, targets: 0 },
          { responsivePriority: 2, targets: 1 }
        ],
        pageLength: 10,
        bPaginate: false,
        bInfo: false,
        bDestroy: true,
        bLengthChange: false, // hide the show number of entries dropdown
        bFilter: false // hide search box
      });

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

    } // / end if browse teams/projects

});
