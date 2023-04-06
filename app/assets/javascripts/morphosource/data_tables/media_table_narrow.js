// Create data table for media works where table may only be half page-width
// This is used in Media Lists to accomodate media preview pane
var createMediaTableNarrow = function(selector) {
  return $(selector).DataTable({
    responsive: {
      details: {
        type: 'none',
        target: ''
      }
    },
    pageLength: 10,
    bPaginate: false,
    bInfo: false,
    bDestroy: true,
    bLengthChange: false, // hide the show number of entries dropdown
    bFilter: false, // hide search box
    ordering: false
  });
};