// Create data table for biological specimen works
var createBiologicalSpecimenTable = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        display: $.fn.dataTable.Responsive.display.childRowImmediate,
        type: ''
      }
    },
    autoWidth: false,
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
    bFilter: false, // hide search box
    ordering: false
  });
};