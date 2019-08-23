$(document).on('turbolinks:load', function() {
  if ($('form[id*="biological_specimen"]').length) { // if BSO form page

    setupEmbeddedWorkForm('new_taxonomy');
    setupEmbeddedWorkForm('new_institution');

	  $('.tooltip-icon').tooltip({ 
	    title: function(){
	      return $(this).find('.hint').text() 
	    } 
	  })
		  
  }
});