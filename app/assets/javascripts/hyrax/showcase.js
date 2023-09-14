$(document).ready(function() {

  if ($('body[class*="showcase"]').length) { // check if the page is showcase page

    setupTooltip();
    
    // switching icons and button labels for expand / collapse
    $(".collapse-block").not(".glyphicon-only").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-bottom"></span> Show more <span class="glyphicon glyphicon-triangle-bottom"></span>');
    });
    $(".collapse-block").not(".glyphicon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<span class="glyphicon glyphicon-triangle-top"></span> Show less <span class="glyphicon glyphicon-triangle-top"></span>');
    });

    // switching icons and button label for simple expand / collapse
    $(".collapse-simple").on("hide.bs.collapse show.bs.collapse", function(event) { 
      let newHtml = '';
      if (event.type == "hide") {
        newHtml = 'Show more <span class="glyphicon glyphicon-triangle-bottom"></span>';
      } else if (event.type == "show") {
        newHtml = 'Show less <span class="glyphicon glyphicon-triangle-top"></span>';
      }

      if (newHtml) {
        $(this).parent(".media-block").children(".collapse-button").children("a").html(newHtml);
      }
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

    if ($('#back-to-top').length) {
      $(window).scroll(function () {
        if ($(this).scrollTop() > 50) {
          $('#back-to-top').fadeIn();
        } else {
          $('#back-to-top').fadeOut();
        }
      });
      // scroll body to 0px on click
      $('#back-to-top').click(function () {
        $('body,html').animate({
          scrollTop: 0
        }, 400);
        return false;
      });
    }

  } // end if the page is showcase page

});
