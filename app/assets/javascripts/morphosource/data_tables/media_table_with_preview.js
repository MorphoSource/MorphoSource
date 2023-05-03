// Create data table for media works with preview pane
// Table may only be half-width and has view column
// This is used in Media Lists
var createMediaTableWithPreview = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        type: 'none',
        target: ''
      }
    },
    columnDefs: [
      { responsivePriority: 1, targets: 0 },
      { responsivePriority: 2, targets: 1 },
      { responsivePriority: 3, targets: 2 },
      { responsivePriority: 3, targets: 3 },
      { responsivePriority: 4, targets: -1 }, // rightmost column
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