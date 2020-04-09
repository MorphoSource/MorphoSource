$(document).on('turbolinks:load', function() {

  if ($('div[class*="showcase"]').length) { // check if the page is showcase page

    var mediaTable = $('#datatable-media-list').DataTable({
      responsive: true,
      columnDefs: [
        { responsivePriority: 1, targets: 0 },
        { responsivePriority: 2, targets: 1 },
        { responsivePriority: 3, targets: 2 },
        { responsivePriority: 4, targets: -1 } // rightmost column
      ],
      pageLength: 10,
      bPaginate: true,
      bDestroy: true,
      bLengthChange: false, // hide the show number of entries dropdown
      bFilter: false // hide search box
    });
    var bsoTable = $('#datatable-bso-list').DataTable({
      responsive: true,
      columnDefs: [
        { responsivePriority: 1, targets: 0 },
        { responsivePriority: 3, targets: 1 },
        { responsivePriority: 4, targets: 2 }
      ],
      pageLength: 10,
      bPaginate: true,
      bDestroy: true,
      bLengthChange: false, // hide the show number of entries dropdown
      bFilter: false // hide search box
    });
    var choTable = $('#datatable-cho-list').DataTable({
      responsive: true,
      columnDefs: [
        { responsivePriority: 1, targets: 0 },
        { responsivePriority: 3, targets: 1 },
        { responsivePriority: 4, targets: 2 }
      ],
      pageLength: 10,
      bPaginate: true,
      bDestroy: true,
      bLengthChange: false, // hide the show number of entries dropdown
      bFilter: false // hide search box
    });

    // Toggle the visibility of table column
    $('.choose-columns-media .toggle-vis').on( 'click', function (e) {
      //e.preventDefault();
      var column = mediaTable.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
    });
    $('.choose-columns-bso .toggle-vis').on( 'click', function (e) {
      var column = bsoTable.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
    });
    $('.choose-columns-cho .toggle-vis').on( 'click', function (e) {
      var column = choTable.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
    });

    // keep dropdown menu open 
    $(document).on('click', '.choose-columns .dropdown-menu', function (e) {
      e.stopPropagation();
    });
    
    // switching icons and button labels for expand / collapse
    $(".collapse-block").not(".glyphicon-only").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-bottom"></span> Show more <span class="glyphicon glyphicon-triangle-bottom"></span>');
    });
    $(".collapse-block").not(".glyphicon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-top"></span> Show less <span class="glyphicon glyphicon-triangle-top"></span>');
    });

    // switching icons only for expand / collapse
    $(".collapse-accordion, .glyphicon-only").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("span."+thisId).removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom")
    });
    $(".collapse-accordion, .glyphicon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("span."+thisId).removeClass("glyphicon-triangle-bottom").addClass("glyphicon-triangle-top")
    });

  } // end if the page is showcase page 

});
