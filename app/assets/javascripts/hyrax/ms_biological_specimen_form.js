$(document).on('turbolinks:load', function() {
  if ($('form[id*="biological_specimen"]').length) { // if BSO form page

    setupEmbeddedWorkForm('new_taxonomy');
    setupEmbeddedWorkForm('new_institution');

	  $('.tooltip-icon').tooltip({ 
	    title: function(){
	      return $(this).find('.hint').text() 
	    } 
	  })

	  // remove the last repeatable field for each group
	  $('.form-group.multi_value').each(function(i) {
	    var lastli = $(this).find('.listing .input-group:last-child');
	    lastli.find('.remove').trigger('click');
	  })
			  
		$('#btn_no_institution').click(function() {
			var removeInstitutionButton = $('#parent-relationships-institutions').find('[data-behavior="remove-relationship"]');
			if (removeInstitutionButton.length) {
				removeInstitutionButton.trigger('click');
			}
		})
  }
});