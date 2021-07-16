$(document).ready(function() {

    if ($('body[class*="media-works"]').length || $('body[class*="teams"]').length) { // check if the page is dashboard media works

    var bsoTable = $('#datatable-bso-list').DataTable({
      responsive: {
        details: {
          display: $.fn.dataTable.Responsive.display.childRowImmediate,
          type: ''
        }
      },
      //order: [[ 1, "asc" ]],
      columnDefs: [
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

  }

});
