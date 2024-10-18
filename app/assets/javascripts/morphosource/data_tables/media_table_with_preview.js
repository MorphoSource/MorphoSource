// Create data table for media works with preview pane
// Table may only be half-width and has view column
// This is used in Media Lists
var createMediaTableWithPreview = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        display: $.fn.dataTable.Responsive.display.childRowImmediate,
        type: 'inline'
      }
    },
    columnDefs: [
      { orderable: false, targets: 0 }, // disable sorting
      { orderable: false, targets: -1 },
      { responsivePriority: 1, targets: 0 },
      { responsivePriority: 3, targets: 1 },
      { responsivePriority: 2, targets: -1 }, // rightmost column
    ],
    pageLength: 10,
    bPaginate: false,
    bInfo: false,
    bDestroy: true,
    bLengthChange: false, // hide the show number of entries dropdown
    bFilter: false, // hide search box
    ordering: false
  });
};