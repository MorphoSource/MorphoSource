$(document).ready(function() {

  if ($('body[class*="showcase"]').length) { // check if the page is showcase page

    setupTooltip();
    
    // switching icons and button labels for expand / collapse
    $(".collapse-block").not(".collapse-icon-only").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<i class="fas fa-chevron-down"></i> Show more <i class="fas fa-chevron-down"></i>');
    });
    $(".collapse-block").not(".collapse-icon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("a."+thisId).html('<i class="fas fa-chevron-up"></i> Show less <i class="fas fa-chevron-up"></i>');
    });

    // switching icons and button label for simple expand / collapse
    $(".collapse-simple").on("hide.bs.collapse show.bs.collapse", function(event) { 
      let newHtml = '';
      if (event.type == "hide") {
        newHtml = 'Show more <i class="fas fa-chevron-down"></i>';
      } else if (event.type == "show") {
        newHtml = 'Show less <i class="fas fa-chevron-up"></i>';
      }

      if (newHtml) {
        $(this).parent(".media-block").children(".collapse-button").children("a").html(newHtml);
      }
    });

    // switching icons only for expand / collapse
    $(".collapse-accordion, .collapse-icon-only").on("hide.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("i."+thisId).removeClass("fa-chevron-up").addClass("fa-chevron-down");
    });
    $(".collapse-accordion, .collapse-icon-only").on("show.bs.collapse", function(){
      var thisId = $(this).attr('id');
      $("i."+thisId).removeClass("fa-chevron-down").addClass("fa-chevron-up");
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
