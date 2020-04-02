$(document).on('turbolinks:load', function() {

  if ($('div[class*="showcase"]').length) { // check if the page is showcase page

    var mediaTable = $('#datatable-media-list').DataTable({
      pageLength: 10
    });
    var bsoTable = $('#datatable-bso-list').DataTable({
      pageLength: 10
    });

      //$('.datatable.teams-projects').DataTable({
      //  // ajax: ...,
      //  // autoWidth: false,
      //  // pagingType: 'full_numbers',
      //  // processing: true,
      //  // serverSide: true,
      //"pageLength": 10
    //
    //  //  // Optional, if you want full pagination controls.
    //  //  // Check dataTables documentation to learn more about available options.
    //  //  // http://datatables.net/reference/option/pagingType
      //});

    // Toggle the visibility of table column
    $('.choose-columns-media .toggle-vis').on( 'click', function (e) {
      //e.preventDefault();
      console.log('click')
      var column = mediaTable.column( $(this).attr('data-column') );
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
