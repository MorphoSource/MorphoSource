var createCollectionsTable = function(selector) {
  return $(selector).DataTable({
  responsive: {
    details: {
      display: $.fn.dataTable.Responsive.display.childRowImmediate,
      type: ''
    }
  },
  autoWidth: false,
  columnDefs: [
    { orderable: false, targets: 0 },
    { orderable: false, responsivePriority: 1, targets: 1 },
    { orderable: false, targets: 2 },
    { orderable: false, targets: 3 },
    { orderable: false, targets: 4 },
    { orderable: false, targets: -1 }
  ],
  pageLength: 10,
  bPaginate: false,
  bInfo: false,
  bDestroy: true,
  bLengthChange: false, // hide the show number of entries dropdown
  bFilter: false // hide search box
  })
};