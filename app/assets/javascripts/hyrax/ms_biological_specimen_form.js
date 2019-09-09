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
			
		// remove institution when clicking no institution button  
		$('#btn_no_institution').click(function() {
			var removeInstitutionButton = $('#parent-relationships-institutions').find('[data-behavior="remove-relationship"]');
			if (removeInstitutionButton.length) {
				removeInstitutionButton.trigger('click');
			}
		})

		// set the institution code field on the object detail tab when an institution has been selected
		$('#btn-add-institution').click(function() {
			$('#biological_specimen_institution_code').val( $('#institution-code').text() );
		})

  }
});