
$(document).on('turbolinks:load', function() {
  if ($('form[id*="biological_specimen"]').length) { // if BSO form page

  	function moveWorkForms() {
			// move the new work forms to inside the tabs
			$("#embedded_div_new_institution").detach().insertAfter('#institution_details');
			//$("#embedded_div_new_taxonomy").detach().insertAfter('#taxonomy_details');
			//$("#embedded_div_new_institution").position({
			//    my:        "left top",
			//    at:        "left top",
			//    of:        $("#institution_details"),
			//    collision: "none",
			//    within: 	 $(".institution-content-block")
			//});
  	}

		function updateObjectTitle() {
			var updatedTitle = $('#biological_specimen_institution_code').val() + ':' +
													$('#biological_specimen_collection_code').val() + ':' +
													$('#biological_specimen_catalog_number').val();
			$('#showcase-title').text(updatedTitle);			
		}

		moveWorkForms();
    setupEmbeddedWorkForm('taxonomy', 'new');
    setupEmbeddedWorkForm('institution', 'new', updateObjectTitle);

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

		// An institution has been selected.  set the institution code field on the object detail tab, then update title
		$('#btn-add-institution').click(function() {
			$('#biological_specimen_institution_code').val( $('#institution-code').text() );
			updateObjectTitle();
		})

		// Change title on the fly when corresponding fields are updated
		$('#biological_specimen_institution_code, #biological_specimen_collection_code, #biological_specimen_catalog_number').change(updateObjectTitle);

		// change badges on the fly when corresponding fields are updated
		$('#biological_specimen_vouchered').change(function(){
			if ($(this).val() == 'Yes')
				$('#in-collection-badge').text('In Collection');
			else
				$('#in-collection-badge').text('Not in Collection');				
		})
		
  }
});