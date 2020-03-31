$(document).on('turbolinks:load', function() {

  if ($('div[class*="showcase"]').length) { // check if the page is showcase page

    // Toggle the visibility of table column
    $('a.toggle-vis').on( 'click', function (e) {
      e.preventDefault();
      var table = $('#teams-projects-listing').DataTable();
      var column = table.column( $(this).attr('data-column') );
      column.visible( ! column.visible() );
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
