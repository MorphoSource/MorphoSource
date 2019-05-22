$(document).on('ready', function(){  
  if ($('div[class*="showcase"]').length) { // check if the page is showcase page
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
      $("a."+thisId).attr('aria-label', 'Expand');
    });
    $(".collapse-accordion, .glyphicon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("span."+thisId).removeClass("glyphicon-triangle-bottom").addClass("glyphicon-triangle-top")
      $("a."+thisId).attr('aria-label', 'Collapse');
    });

  } // end if the page is showcase page 
});
