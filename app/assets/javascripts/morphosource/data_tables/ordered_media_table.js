// Create data table for media works
var createOrderedMediaTable = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        type: 'column' // hide the details and button in responsive
      }
    },
    //order: [[ 2, "asc" ]],  // if sorting is needed, we might need to sort the same way in gallery view
    columnDefs: [
      { orderable: false, targets: 0 }, // disable sorting
      { orderable: false, targets: 1 },
      //{ visible: false, targets: 9 }, // hide column by default
      //{ width: "20%", targets: -1 },
      { responsivePriority: 1, targets: 0 },
      { responsivePriority: 2, targets: 1 },
      { responsivePriority: 3, targets: 3 },
      { responsivePriority: 4, targets: 4 },
      { responsivePriority: 5, targets: 5 },
      { responsivePriority: 6, targets: 6 },
      { responsivePriority: 7, targets: 2 },
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