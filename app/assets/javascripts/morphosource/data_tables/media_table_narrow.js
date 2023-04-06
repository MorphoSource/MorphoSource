// Create data table for media works where table may only be half page-width
// This is used in Media Lists to accomodate media preview pane
var createMediaTableNarrow = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        type: 'column' // hide the details and button in responsive
      }
    },
    //order: [[ 2, "asc" ]],  // if sorting is needed, we might need to sort the same way in gallery view
    columnDefs: [ // No ordering first two columns, for responsive mostly retain left elements
      { orderable: false, targets: 0 }, // Interactive elements (checkbox etc) column, no ordering
      { orderable: false, targets: 1 }, // Thumbnail column, no ordering
      { responsivePriority: 1, targets: 0 }, // Interactive elements (checkbox etc)
      { responsivePriority: 2, targets: 1 }, // Thumbnail
      { responsivePriority: 3, targets: 3 }, // Part
      { responsivePriority: 4, targets: 4 }, // Object
      { responsivePriority: 5, targets: 5 }, // Taxonomy
      { responsivePriority: 6, targets: 6 }, // Type
      { responsivePriority: 7, targets: 2 }, // ID
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