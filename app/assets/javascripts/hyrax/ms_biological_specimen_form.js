
$(document).on('turbolinks:load', function() {
  if ($('form[id*="edit_biological_specimen"]').length) { // if BSO form page

		function updateObjectTitle() {
			var title = [ $('#biological_specimen_institution_code').val(),
													$('#biological_specimen_collection_code').val(),
													$('#biological_specimen_catalog_number').val() ]
			title = $.map( title, function(v){ return v === "" ? null : v; });
			$('#showcase-title').text(title.join(':'));			
		}

    setupEmbeddedWorkForm('taxonomy', 'new', false);
    setupEmbeddedWorkForm('organization', 'new', false, updateObjectTitle);
    setupTooltip();
		removeLastRepeatable();
					
		// remove organization when clicking no organization button  
		$('#btn_no_organization').click(function() {
			var removeOrganizationButton = $('#parent-relationships-organizations').find('[data-behavior="remove-relationship"]');
			if (removeOrganizationButton.length) {
				removeOrganizationButton.trigger('click');
			}
			$('#embedded_div_new_organization').hide();
			$('#biological_specimen_institution_code').val('');
			updateObjectTitle();
		})

		// An organization has been selected.  set the institution code field on the object detail tab, then update title
		$('#btn-add-organization').click(function() {
			$('#biological_specimen_institution_code').val( $('#organization-code').text() );
			updateObjectTitle();
		})

		// when selecting an organization or taxonomy, hide the new work form if any
		$('[data-behavior="add-relationship"]').click(function() {
			$('.embedded_div').hide();
		})

		// when switching to another tab, hide the new work form from other tab if any
		$('.nav-tabs > li').click(function() {
			if ($(this).find('a[aria-expanded="false"]').length)
				$('.embedded_div').hide();
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

	  $(document).on("submit", 'form[data-param-key="biological_specimen"]', function() {
			$('.btn').addClass('disabled');
		})

  }
});